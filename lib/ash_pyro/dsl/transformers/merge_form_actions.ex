defmodule AshPyro.Dsl.Transformers.MergeFormActions do
  @moduledoc false

  use AshPyro.Dsl.Transformers

  alias Ash.Resource
  alias AshPyro.Form.{Action, ActionType, Field, FieldGroup}
  alias Spark.Dsl.Transformer
  alias Spark.Error.DslError

  @ash_resource_transformers Resource.Dsl.transformers()

  @impl true
  def after?(module) when module in @ash_resource_transformers, do: true

  @impl true
  def after?(_), do: false

  @impl true
  def transform(dsl) do
    if [] == Transformer.get_entities(dsl, [:form]) do
      {:ok, dsl}
    else
      {:ok, merge_form(dsl)}
    end
  end

  defp merge_form(dsl) do
    context = %{
      default_class: Transformer.get_option(dsl, [:form], :class, nil),
      default_description: Transformer.get_option(dsl, [:form], :description, nil),
      dsl: dsl,
      excluded_actions: Transformer.get_option(dsl, [:form], :exclude, []),
      module: Transformer.get_persisted(dsl, :module, nil),
      resource_actions: get_resource_actions(dsl) |> Enum.reduce(%{}, &Map.put(&2, &1.name, &1))
    }

    actions =
      for %Action{name: names} = action <-
            Transformer.get_entities(dsl, [:form]),
          name <- names do
        %{action | name: name}
        |> merge_action(context)
      end

    action_types =
      for %ActionType{name: names} = action_type <-
            Transformer.get_entities(dsl, [:form]),
          name <- names,
          into: %{} do
        {name, %{action_type | name: name}}
      end

    dsl =
      Transformer.remove_entity(dsl, [:form], fn
        %ActionType{} -> true
        %Action{} -> true
        _ -> false
      end)

    default_actions =
      for name <- expected_actions(context, actions) do
        %{type: type} = Map.fetch!(context.resource_actions, name)

        action_type =
          Map.get(action_types, type) ||
            raise DslError.exception(
                    module: context.module,
                    path: [:form],
                    message: """
                    form for action #{inspect(name)} is not defined or excluded, and no defaults for type #{inspect(type)} exist
                    """
                  )

        action_type
        |> Map.delete(:__struct__)
        |> Map.put(:name, name)
        |> then(fn action -> struct!(Action, action) end)
        |> merge_action(context)
      end

    Enum.reduce(actions ++ default_actions, dsl, fn action, dsl ->
      Transformer.add_entity(dsl, [:form], action, prepend: true)
    end)
  end

  defp expected_actions(context, actions) do
    already_defined = MapSet.new(actions, & &1.name)

    context.resource_actions
    |> Map.values()
    |> Enum.filter(&(&1.name not in context.excluded_actions && &1.type in [:create, :update]))
    |> MapSet.new(& &1.name)
    |> MapSet.difference(already_defined)
  end

  defp merge_action(%Action{name: name} = action, context) do
    resource_action =
      Map.get(context.resource_actions, name) ||
        raise DslError.exception(
                module: context.module,
                path: [:form, :action],
                message: """
                action #{inspect(name)} not found in resource
                """
              )

    if resource_action.type not in [:create, :update] do
      raise DslError.exception(
              module: context.module,
              path: [:form, :action],
              message: """
              action #{inspect(name)} is an unsupported type: #{inspect(resource_action.type)}
              """
            )
    end

    if name in context.excluded_actions do
      raise DslError.exception(
              module: context.module,
              path: [:form, :action],
              message: """
              action #{inspect(name)} is listed in exclude
              """
            )
    end

    action
    |> Map.put(:label, action.label || default_label(name))
    |> Map.put(:class, action.class || context.default_class)
    |> expand_action_description(context)
    |> Map.put(:fields, merge_fields(action.fields, context))
  end

  defp merge_fields(fields, context, root_path \\ []) do
    Enum.map(fields, fn
      %Field{} = field ->
        field
        |> Map.put(:path, maybe_append_path(root_path, field.path))
        |> Map.put(:label, field.label || default_label(field))
        |> expand_field_description(context)

      %FieldGroup{} = group ->
        group_path = maybe_append_path(root_path, group.path)

        group
        |> Map.put(:path, group_path)
        |> Map.put(:label, group.label || default_label(group))
        |> expand_field_description(context)
        |> Map.put(:fields, merge_fields(group.fields, context, group_path))
    end)
  end

  defp expand_action_description(action, context) do
    description = Map.get(action, :description, context.default_description)

    description =
      if description == :inherit do
        Map.get(context.resource_action, :description)
      else
        description
      end

    Map.put(action, :description, description)
  end

  defp expand_field_description(%{description: :inherit} = field, context) do
    description =
      context.resource
      |> AshPyro.Info.resource_by_path(field.path)
      |> Resource.Info.field(field.name)
      |> Map.get(:description)

    Map.put(field, :description, description)
  end

  defp expand_field_description(field, _context), do: field
end
