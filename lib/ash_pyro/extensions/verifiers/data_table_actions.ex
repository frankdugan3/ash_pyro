defmodule AshPyro.Extensions.Verifiers.DataTableActions do
  @moduledoc false

  use AshPyro.Extensions.Verifiers

  alias Ash.Resource.Info
  alias AshPyro.Extensions.Dsl.DataTable
  alias Spark.Dsl.Extension

  @impl true
  def verify(dsl_state) do
    data_table_actions = Verifier.get_entities(dsl_state, [:pyro, :data_table])

    check_actions(data_table_actions, dsl_state)
    check_actions_for_duplicate_labels(data_table_actions)

    :ok
  end

  defp check_actions(data_table_actions, dsl_state) do
    Enum.each(data_table_actions, fn action ->
      check_action(action, dsl_state)
    end)
  end

  defp check_action(%DataTable.Action{} = action, dsl_state) do
    resource = Extension.get_persisted(dsl_state, :module)

    public_fields =
      dsl_state
      |> Info.public_fields()
      |> MapSet.new(& &1.name)

    private_fields =
      dsl_state
      |> Info.fields()
      |> Enum.filter(&(!&1.public?))
      |> MapSet.new(& &1.name)

    check_action_for_duplicate_path_names(action)
    check_action_for_duplicate_path_labels(action)
    check_action_for_public_field_inclusion(action, public_fields)
    validate_action_default_sort(action, resource)
    validate_action_default_display(action)
    validate_action_columns(action, public_fields, private_fields)
  end

  defp check_action_for_duplicate_path_names(%DataTable.Action{
         columns: columns,
         name: action_name
       }) do
    columns
    |> Enum.group_by(fn %{name: name, path: path} ->
      path
      |> Kernel.++([name])
      |> Enum.join(".")
    end)
    |> Enum.each(fn {name, groups} ->
      name_count = Enum.count(groups)

      if name_count > 1 do
        {:error,
         DslError.exception(
           path: [:pyro, :data_table, :action, action_name, name],
           message:
             "action #{inspect(action_name)}, #{name_count} columns duplicate the path/name #{inspect(name)}"
         )}
        |> raise_error()
      end
    end)
  end

  defp check_action_for_duplicate_path_labels(%DataTable.Action{
         columns: columns,
         name: action_name
       }) do
    columns
    |> Enum.group_by(fn %{label: label, path: path} ->
      path
      |> Kernel.++([label])
      |> Enum.join(".")
    end)
    |> Enum.each(fn {label, groups} ->
      label_count = Enum.count(groups)

      if label_count > 1 do
        {:error,
         DslError.exception(
           path: [:pyro, :data_table, :action, action_name, label],
           message:
             "action #{inspect(action_name)}, #{label_count} columns duplicate the path/label #{inspect(label)}"
         )}
        |> raise_error()
      end
    end)
  end

  defp check_action_for_public_field_inclusion(
         %DataTable.Action{columns: columns, exclude: exclude, name: action_name},
         public_fields
       ) do
    public_fields
    |> Enum.filter(&(&1 not in exclude))
    |> Enum.each(fn name ->
      if !Enum.find(columns, &(&1.path == [] && &1.name == name)) do
        {:error,
         DslError.exception(
           path: [:pyro, :data_table, :action, action_name],
           message: "action #{inspect(action_name)}, attribute #{inspect(name)} not in columns"
         )}
        |> raise_error()
      end
    end)
  end

  defp validate_action_default_sort(
         %DataTable.Action{
           columns: columns,
           default_display: default_display,
           default_sort: default_sort,
           name: action_name
         },
         resource
       ) do
    case Ash.Sort.parse_input(resource, default_sort) do
      {:ok, nil} ->
        :ok

      {:ok, sort} when is_list(sort) ->
        sort_fields = Keyword.keys(sort)
        Enum.each(sort_fields, &validate_sort_field(&1, action_name, columns, default_display))

      {:error, error} ->
        {:error,
         DslError.exception(
           path: [:pyro, :data_table, :action, action_name, :default_sort],
           message: Ash.ErrorKind.message(error)
         )}
        |> raise_error()
    end
  end

  defp validate_action_default_display(%DataTable.Action{
         columns: columns,
         default_display: default_display,
         name: action_name
       }) do
    Enum.each(default_display, fn field ->
      if !Enum.find(columns, &(&1.name == field)) do
        {:error,
         DslError.exception(
           path: [
             :pyro,
             :data_table,
             :action,
             action_name,
             :default_display
           ],
           message:
             "action #{inspect(action_name)}, display field #{inspect(field)} not in columns"
         )}
        |> raise_error()
      end
    end)
  end

  defp validate_sort_field(field, action_name, columns, default_display) do
    if !Enum.find(columns, &(&1.name == field)) do
      {:error,
       DslError.exception(
         path: [:pyro, :data_table, :action, action_name, :default_sort],
         message: "action #{inspect(action_name)}, sort field #{inspect(field)} not in columns"
       )}
      |> raise_error()
    end

    if !Enum.find(default_display, &(&1 == field)) do
      {:error,
       DslError.exception(
         path: [:pyro, :data_table, :action, action_name, :default_display],
         message:
           "action #{inspect(action_name)}, sort field #{inspect(field)} not in default display"
       )}
      |> raise_error()
    end
  end

  defp validate_action_columns(
         %DataTable.Action{columns: columns, name: action_name},
         public_fields,
         private_fields
       ) do
    Enum.each(columns, fn
      %{name: column_name, path: []} ->
        cond do
          MapSet.member?(public_fields, column_name) ->
            :ok

          MapSet.member?(private_fields, column_name) ->
            {:error,
             DslError.exception(
               path: [:pyro, :data_table, :action, action_name],
               message:
                 "action #{inspect(action_name)}, #{inspect(column_name)} is not a public field"
             )}
            |> raise_error()

          true ->
            {:error,
             DslError.exception(
               path: [:pyro, :data_table, :action, action_name],
               message:
                 "action #{inspect(action_name)}, #{inspect(column_name)} is not an attribute, aggregate, calculation or relationship"
             )}
            |> raise_error()
        end

      _ ->
        :ok
    end)
  end

  defp check_actions_for_duplicate_labels([]), do: :ok

  defp check_actions_for_duplicate_labels(data_table_actions) do
    data_table_actions
    |> Enum.group_by(& &1.label)
    |> Enum.each(fn {label, groups} ->
      label_count = Enum.count(groups)

      if label_count > 1 do
        {:error,
         DslError.exception(
           path: [:pyro, :data_table, :action],
           message: "#{label_count} actions share the label #{inspect(label)}"
         )}
        |> raise_error()
      end
    end)
  end

  defp raise_error({:error, exception}), do: raise(exception)
end
