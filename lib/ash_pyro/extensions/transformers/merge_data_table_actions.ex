defmodule AshPyro.Extensions.Resource.Transformers.MergeDataTableActions do
  @moduledoc false

  use AshPyro.Extensions.Resource.Transformers

  alias Ash.Resource.Dsl
  alias Ash.Resource.Info
  alias AshPyro.Extensions.Dsl.DataTable

  @ash_resource_transformers Dsl.transformers()

  @impl true
  def after?(module) when module in @ash_resource_transformers, do: true
  @impl true
  def after?(_), do: false

  @impl true
  def transform(dsl) do
    case Transformer.get_entities(dsl, [:pyro, :data_table]) do
      [] ->
        {:ok, dsl}

      data_table_entities ->
        excluded_data_table_action_names =
          Transformer.get_option(dsl, [:pyro, :data_table], :exclude, [])

        # truncate all Action/ActionType entities because they will be unrolled/defaulted
        dsl =
          Transformer.remove_entity(dsl, [:pyro, :data_table], fn
            %DataTable.ActionType{} -> true
            %DataTable.Action{} -> true
            _ -> false
          end)

        # determine the actions that need data table definitions
        expected_action_names =
          dsl
          |> filter_actions(fn action ->
            action.name not in excluded_data_table_action_names &&
              action.type in [:read]
          end)
          |> Enum.map(& &1.name)

        %{
          data_table_actions: data_table_actions,
          data_table_types: data_table_types,
          to_find: to_find
        } =
          data_table_entities
          |> Enum.reduce(
            %{
              data_table_actions: [],
              data_table_types: %{},
              dsl: dsl,
              exclusions: excluded_data_table_action_names,
              to_find: expected_action_names
            },
            &reduce_data_table_entities/2
          )

        data_table_actions =
          merge_defaults_from_types(data_table_actions, to_find, dsl, data_table_types)

        dsl =
          Enum.reduce(data_table_actions, dsl, fn data_table_action, dsl ->
            Transformer.add_entity(dsl, [:pyro, :data_table], data_table_action, prepend: true)
          end)

        {:ok, dsl}
    end
  end

  defp reduce_data_table_entities(%DataTable.ActionType{name: names} = type, acc)
       when is_list(names) do
    columns = merge_columns(type.columns, acc)

    Enum.reduce(names, acc, fn name, acc ->
      merge_action_type(
        acc,
        type
        |> Map.put(:name, name)
        |> Map.put(:columns, columns)
      )
    end)
  end

  defp reduce_data_table_entities(%DataTable.ActionType{} = type, acc) do
    columns = merge_columns(type.columns, acc)
    merge_action_type(acc, Map.put(type, :columns, columns))
  end

  defp reduce_data_table_entities(%DataTable.Action{name: names} = action, acc)
       when is_list(names) do
    columns = merge_columns(action.columns, acc)

    Enum.reduce(names, acc, fn name, acc ->
      merge_action(
        acc,
        action
        |> Map.put(:name, name)
        |> Map.put(:columns, columns)
      )
    end)
  end

  defp reduce_data_table_entities(%DataTable.Action{} = action, acc) do
    columns = merge_columns(action.columns, acc)
    merge_action(acc, Map.put(action, :columns, columns))
  end

  defp reduce_data_table_entities(_, acc) do
    acc
  end

  defp merge_action_type(_acc, %{name: name}) when name not in [:read] do
    {:error,
     DslError.exception(
       path: [:pyro, :data_table, :action_type],
       message: """
       unsupported action type: #{name}
       """
     )}
    |> raise_error()
  end

  defp merge_action_type(%{data_table_types: %{read: _}}, %{name: :read}) do
    {:error,
     DslError.exception(
       path: [:pyro, :data_table, :action_type],
       message: """
       action type :read has already been defined
       """
     )}
    |> raise_error()
  end

  defp merge_action_type(%{data_table_types: types} = acc, %{name: name} = type) do
    types = Map.put(types, name, type)
    Map.put(acc, :data_table_types, types)
  end

  defp merge_action(acc, %{name: name} = data_table_action) do
    case validate_action_and_type(acc.dsl, name) do
      {:error, error} ->
        raise_error({:error, error})

      {:ok, action} ->
        if name in acc.exclusions do
          {:error,
           DslError.exception(
             path: [:pyro, :data_table, :action],
             message: """
             action #{name} is listed in `exclude`
             """
           )}
          |> raise_error()
        else
          default_display =
            if data_table_action.default_display == [] do
              Enum.map(data_table_action.columns, & &1.name)
            else
              data_table_action.default_display
            end

          data_table_action =
            data_table_action
            |> Map.put(:label, data_table_action.label || default_label(name))
            |> Map.put(:default_display, default_display)
            |> Map.put(:default_sort, data_table_action.default_sort)
            |> Map.put(
              :description,
              data_table_action.description || Map.get(action, :description)
            )

          data_table_actions = [data_table_action | acc.data_table_actions]
          to_find = Enum.reject(acc.to_find, &(&1 == name))

          acc
          |> Map.put(:data_table_actions, data_table_actions)
          |> Map.put(:to_find, to_find)
        end
    end
  end

  defp validate_action_and_type(dsl, name) do
    action = get_action(dsl, name)

    case action do
      nil ->
        {:error,
         DslError.exception(
           path: [:pyro, :data_table, :action],
           message: """
           action #{name} does not exist on this resource
           """
         )}

      %{type: type} when type not in [:read] ->
        {:error,
         DslError.exception(
           path: [:pyro, :data_table, :action],
           message: """
           action #{name} is an unsupported type: #{type}
           """
         )}

      action ->
        {:ok, action}
    end
  end

  defp merge_defaults_from_types(data_table_actions, [], _dsl, _data_table_types),
    do: data_table_actions

  defp merge_defaults_from_types(data_table_actions, to_find, dsl, data_table_types) do
    # Create an accumulator similar to the original logic but without error collection
    acc = %{
      dsl: dsl,
      data_table_actions: data_table_actions,
      data_table_types: data_table_types,
      to_find: to_find,
      # exclusions were already filtered out earlier
      exclusions: []
    }

    final_acc = Enum.reduce(to_find, acc, &process_default_data_table_action/2)
    final_acc.data_table_actions
  end

  defp process_default_data_table_action(name, acc) do
    case validate_action_and_type(acc.dsl, name) do
      {:error, error} ->
        raise_error({:error, error})

      {:ok, action} ->
        handle_data_table_action_with_type_default(acc, name, action)
    end
  end

  defp handle_data_table_action_with_type_default(acc, name, action) do
    type_default = Map.get(acc.data_table_types, action.type)

    if type_default == nil do
      {:error,
       DslError.exception(
         path: [:pyro, :data_table],
         message: """
         data table for action #{name} is not defined, has no type defaults, and is not excluded
         """
       )}
      |> raise_error()
    else
      merge_action(
        acc,
        Map.merge(
          %DataTable.Action{name: name},
          Map.drop(type_default, [:__struct__, :name])
        )
      )
    end
  end

  defp merge_columns(columns, acc, path \\ []) do
    Enum.map(columns, fn
      %DataTable.Column{} = column ->
        sortable? =
          if column.sortable? == true do
            # TODO: Take :pagination_type into account
            Info.sortable?(acc.dsl, column.name, include_private?: false)
          else
            column.sortable?
          end

        column
        |> Map.put(:label, column.label || default_label(column))
        |> Map.put(:path, maybe_append_path(path, column.path))
        |> Map.put(:resource_field_type, resource_field_type(acc.dsl, column.name))
        |> Map.put(:sortable?, sortable?)
    end)
  end

  defp raise_error({:error, exception}), do: raise(exception)

  defp maybe_append_path(root, nil), do: root
  defp maybe_append_path(root, []), do: root
  defp maybe_append_path(root, path), do: root ++ List.wrap(path)
end
