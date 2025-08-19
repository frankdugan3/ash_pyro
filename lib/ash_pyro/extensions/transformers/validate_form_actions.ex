defmodule AshPyro.Extensions.Resource.Verifiers.FormActions do
  @moduledoc false

  use AshPyro.Extensions.Resource.Verifiers

  alias AshPyro.Extensions.Dsl.Form

  @impl true
  def verify(dsl_state) do
    validation_context = build_validation_context(dsl_state)

    # Validate each form action
    Enum.each(validation_context.form_actions, &validate_form_action(&1, validation_context))

    # Check for duplicate action labels
    validate_action_labels(validation_context.form_actions)

    :ok
  end

  defp build_validation_context(dsl_state) do
    {public_attributes, private_attributes} =
      dsl_state
      |> Verifier.get_entities([:attributes])
      |> Enum.split_with(& &1.public?)

    {writable_attributes, unwritable_attributes} =
      Enum.split_with(public_attributes, & &1.writable?)

    %{
      actions: Verifier.get_entities(dsl_state, [:actions]),
      form_actions: Verifier.get_entities(dsl_state, [:pyro, :form]),
      private_attribute_names: MapSet.new(private_attributes, & &1.name),
      unwritable_attribute_names: MapSet.new(unwritable_attributes, & &1.name),
      writable_attribute_names: MapSet.new(writable_attributes, & &1.name)
    }
  end

  defp validate_form_action(%Form.Action{fields: fields, name: action_name}, context) do
    all = flatten_fields(fields)

    validate_duplicate_paths(all, action_name)
    validate_duplicate_labels(all, action_name)
    validate_action_exists(action_name, all, context)
  end

  defp validate_duplicate_paths(all, action_name) do
    all
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
           path: [:pyro, :form, :action, action_name, name],
           message: "#{name_count} field/field_groups duplicate the path/name #{name}"
         )}
        |> raise_error()
      end
    end)
  end

  defp validate_duplicate_labels(all, action_name) do
    all
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
           path: [:pyro, :form, :action, action_name, label],
           message: "#{label_count} field/field_groups duplicate the path/label #{label}"
         )}
        |> raise_error()
      end
    end)
  end

  defp validate_action_exists(action_name, all, context) do
    case Enum.find(context.actions, &(&1.name == action_name)) do
      nil ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "action #{action_name} does not exist on this resource"
         )}
        |> raise_error()

      %{type: type} when type not in [:create, :update, :delete] ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "action #{action_name} is an unsupported type: #{type}"
         )}
        |> raise_error()

      action ->
        validate_action_details(action, action_name, all, context)
    end
  end

  defp validate_action_details(action, action_name, all, context) do
    all_fields = Enum.filter(all, &(&1.__struct__ == Form.Field))

    validate_autofocus(all_fields, action_name)
    validate_accepted_attributes(action, action_name, all_fields, context)
    validate_field_attributes(action, action_name, all_fields, context)
  end

  defp validate_autofocus(all_fields, action_name) do
    case Enum.count(all_fields, &(&1.autofocus == true)) do
      0 ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "exactly one field must have autofocus"
         )}
        |> raise_error()

      1 ->
        :ok

      count ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "#{count} autofocus fields; exactly one field must have autofocus"
         )}
        |> raise_error()
    end
  end

  defp validate_accepted_attributes(action, action_name, all_fields, context) do
    action.accept
    |> Enum.filter(&(&1 in context.writable_attribute_names))
    |> Enum.each(fn name ->
      if !Enum.find(all_fields, &(&1.path == [] && &1.name == name)) do
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "action #{action_name}: attribute #{name} not in form fields"
         )}
        |> raise_error()
      end
    end)
  end

  defp validate_field_attributes(action, action_name, all_fields, context) do
    Enum.each(all_fields, fn
      %{name: field_name, path: []} ->
        validate_field_attribute(action, action_name, field_name, context)

      _ ->
        :ok
    end)
  end

  defp validate_field_attribute(action, action_name, field_name, context) do
    matching_argument = Enum.find(action.arguments, &(&1.name == field_name))

    cond do
      field_name not in action.accept && !matching_argument ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message:
             "action #{action_name}: #{field_name} is not an accepted attribute or argument"
         )}
        |> raise_error()

      MapSet.member?(context.writable_attribute_names, field_name) ->
        :ok

      # TODO: Validate arguments
      !!matching_argument ->
        :ok

      # Check these after argument validation, or will get false positives on private attributes
      MapSet.member?(context.private_attribute_names, field_name) ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "action #{action_name}: #{field_name} is not a public attribute"
         )}
        |> raise_error()

      MapSet.member?(context.unwritable_attribute_names, field_name) ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "action #{action_name}: #{field_name} is an unwritable attribute"
         )}
        |> raise_error()

      true ->
        {:error,
         DslError.exception(
           path: [:pyro, :form, :action, action_name],
           message: "action #{action_name}: #{field_name} is not an attribute"
         )}
        |> raise_error()
    end
  end

  defp validate_action_labels(form_actions) do
    if !Enum.empty?(form_actions) do
      form_actions
      |> Enum.group_by(& &1.label)
      |> Enum.each(&check_duplicate_label/1)
    end
  end

  defp check_duplicate_label({label, groups}) do
    label_count = Enum.count(groups)

    if label_count > 1 do
      {:error,
       DslError.exception(
         path: [:pyro, :form, :action],
         message: "#{label_count} actions share the label #{label}"
       )}
      |> raise_error()
    end
  end

  defp raise_error({:error, exception}), do: raise(exception)

  defp flatten_fields(fields),
    do:
      Enum.reduce(fields, [], fn
        %Form.FieldGroup{fields: fields} = field_group, acc ->
          Enum.concat(flatten_fields(fields), [%{field_group | fields: []} | acc])

        field, acc ->
          [field | acc]
      end)
end
