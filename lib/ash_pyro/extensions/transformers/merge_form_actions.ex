defmodule AshPyro.Extensions.Resource.Transformers.MergeFormActions do
  @moduledoc false

  use AshPyro.Extensions.Resource.Transformers

  alias Ash.Resource.Dsl
  alias AshPyro.Extensions.Dsl.Form

  @ash_resource_transformers Dsl.transformers()

  @impl true
  def after?(module) when module in @ash_resource_transformers, do: true
  @impl true
  def after?(_), do: false

  @impl true
  def transform(dsl) do
    case Transformer.get_entities(dsl, [:pyro, :form]) do
      [] ->
        {:ok, dsl}

      form_entities ->
        # convert to a map for fast access later
        actions =
          dsl
          |> Transformer.get_entities([:actions])
          |> Enum.reduce(%{}, &Map.put(&2, &1.name, &1))

        excluded_form_action_names =
          Transformer.get_option(dsl, [:pyro, :form], :exclude, [])

        # determine the actions that need form definitions
        expected_action_names =
          actions
          |> Map.values()
          |> Enum.filter(fn action ->
            action.name not in excluded_form_action_names &&
              action.type in [:create, :update]
          end)
          # TODO: Perhaps detect special forms of :destroy types that take arguments?
          |> Enum.map(& &1.name)

        %{form_actions: form_actions, form_types: form_types, to_find: to_find} =
          form_entities
          |> Enum.reduce(
            %{
              actions: actions,
              exclusions: excluded_form_action_names,
              form_actions: [],
              form_types: %{},
              to_find: expected_action_names
            },
            fn
              %Form.ActionType{name: names} = type, acc when is_list(names) ->
                fields = merge_fields(type.fields)
                Enum.reduce(names, acc, &merge_action_type_with_name(&1, &2, type, fields))

              %Form.ActionType{} = type, acc ->
                fields = merge_fields(type.fields)
                merge_action_type(acc, Map.put(type, :fields, fields))

              %Form.Action{name: names} = action, acc when is_list(names) ->
                fields = merge_fields(action.fields)
                Enum.reduce(names, acc, &merge_action_with_name(&1, &2, action, fields))

              %Form.Action{} = action, acc ->
                fields = merge_fields(action.fields)
                merge_action(acc, Map.put(action, :fields, fields))

              _, acc ->
                acc
            end
          )

        form_actions = merge_defaults_from_types(form_actions, to_find, actions, form_types)

        # truncate all Action/ActionType entities because they will be unrolled/defaulted
        dsl =
          Transformer.remove_entity(dsl, [:pyro, :form], fn
            %Form.ActionType{} -> true
            %Form.Action{} -> true
            _ -> false
          end)

        dsl =
          Enum.reduce(form_actions, dsl, fn form_action, dsl ->
            Transformer.add_entity(dsl, [:pyro, :form], form_action, prepend: true)
          end)

        {:ok, dsl}
    end
  end

  defp merge_action_type(_acc, %{name: name}) when name not in [:create, :update, :destroy] do
    {:error,
     DslError.exception(
       path: [:pyro, :form, :action_type],
       message: """
       unsupported action type: #{name}
       """
     )}
    |> raise_error()
  end

  defp merge_action_type(%{form_types: %{create: _}}, %{name: :create}) do
    {:error,
     DslError.exception(
       path: [:pyro, :form, :action_type],
       message: """
       action type :create has already been defined
       """
     )}
    |> raise_error()
  end

  defp merge_action_type(%{form_types: %{update: _}}, %{name: :update}) do
    {:error,
     DslError.exception(
       path: [:pyro, :form, :action_type],
       message: """
       action type :update has already been defined
       """
     )}
    |> raise_error()
  end

  defp merge_action_type(%{form_types: %{destroy: _}}, %{name: :destroy}) do
    {:error,
     DslError.exception(
       path: [:pyro, :form, :action_type],
       message: """
       action type :destroy has already been defined
       """
     )}
    |> raise_error()
  end

  defp merge_action_type(%{form_types: types} = acc, %{name: name} = type) do
    types = Map.put(types, name, type)
    Map.put(acc, :form_types, types)
  end

  defp merge_action_with_name(name, acc, action, fields) do
    merge_action(
      acc,
      action
      |> Map.put(:name, name)
      |> Map.put(:fields, fields)
    )
  end

  defp merge_action_type_with_name(name, acc, type, fields) do
    merge_action_type(
      acc,
      type
      |> Map.put(:name, name)
      |> Map.put(:fields, fields)
    )
  end

  defp merge_action(acc, %{name: name} = form_action) do
    case validate_action_and_type(acc.actions, name) do
      {:error, error} ->
        raise_error({:error, error})

      {:ok, action} ->
        if name in acc.exclusions do
          {:error,
           DslError.exception(
             path: [:pyro, :form, :action],
             message: """
             action #{name} is listed in `exclude`
             """
           )}
          |> raise_error()
        else
          form_action =
            form_action
            |> Map.put(:label, form_action.label || default_label(name))
            |> Map.put(:description, form_action.description || Map.get(action, :description))

          form_actions = [form_action | acc.form_actions]
          to_find = Enum.reject(acc.to_find, &(&1 == name))

          acc
          |> Map.put(:form_actions, form_actions)
          |> Map.put(:to_find, to_find)
        end
    end
  end

  defp validate_action_and_type(actions, name) do
    action = Map.get(actions, name)

    case action do
      nil ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action],
           message: """
           action #{name} not found in resource
           """
         )}

      %{type: type} when type not in [:create, :update, :destroy] ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action],
           message: """
           action #{name} is an unsupported type: #{type}
           """
         )}

      action ->
        {:ok, action}
    end
  end

  defp merge_defaults_from_types(form_actions, [], _actions, _form_types), do: form_actions

  defp merge_defaults_from_types(form_actions, to_find, actions, form_types) do
    # actions is already a map from the transform function

    # Create an accumulator similar to the original logic but without error collection
    acc = %{
      form_actions: form_actions,
      form_types: form_types,
      to_find: to_find,
      # exclusions were already filtered out earlier
      exclusions: [],
      actions: actions
    }

    final_acc = Enum.reduce(to_find, acc, &process_default_action/2)
    final_acc.form_actions
  end

  defp process_default_action(name, acc) do
    case validate_action_and_type(acc.actions, name) do
      {:error, error} ->
        raise_error({:error, error})

      {:ok, action} ->
        handle_action_with_type_default(acc, name, action)
    end
  end

  defp handle_action_with_type_default(acc, name, action) do
    type_default = Map.get(acc.form_types, action.type)

    if type_default == nil do
      {:error,
       DslError.exception(
         path: [:pyro, :form],
         message: """
         form for action #{name} is not defined, has no type defaults, and is not excluded
         """
       )}
      |> raise_error()
    else
      merge_action(
        acc,
        Map.merge(%Form.Action{name: name}, Map.drop(type_default, [:__struct__, :name]))
      )
    end
  end

  defp merge_fields(fields, path \\ []) do
    Enum.map(fields, fn
      %Form.Field{} = field ->
        field
        |> Map.put(:label, field.label || default_label(field))
        |> Map.put(:path, maybe_append_path(path, field.path))

      %Form.FieldGroup{} = group ->
        path = maybe_append_path(path, group.path)

        group
        |> Map.put(:label, group.label || default_label(group))
        |> Map.put(:path, path)
        |> Map.put(:fields, merge_fields(group.fields, path))
    end)
  end

  defp raise_error({:error, exception}), do: raise(exception)

  defp maybe_append_path(root, nil), do: root
  defp maybe_append_path(root, []), do: root
  defp maybe_append_path(root, path), do: root ++ List.wrap(path)
end
