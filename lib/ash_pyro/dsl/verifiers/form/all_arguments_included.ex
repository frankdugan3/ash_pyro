defmodule AshPyro.Dsl.Verifiers.Form.AllArgumentsIncluded do
  @moduledoc """
  Ensures all arguments for each action are included in the form.
  """

  use AshPyro.Dsl.Verifiers

  alias Ash.Resource.Info, as: ResourceInfo
  alias AshPyro.Form.{Action, FieldGroup, Field}

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)
    resource = Verifier.get_persisted(dsl, :resource, nil)

    for %Action{name: action_name} = action <-
          Verifier.get_entities(dsl, [:form]) do
      fields = argument_fields(action.fields)

      for argument <- ResourceInfo.action(resource, action_name).arguments do
        if !MapSet.member?(fields, argument.name) do
          raise DslError.exception(
                  module: module,
                  path: [:form, :action, action_name],
                  message: "argument #{inspect(argument.name)} is not a field"
                )
        end
      end
    end

    :ok
  end

  defp argument_fields(fields) do
    Enum.reduce(fields, MapSet.new(), fn
      %FieldGroup{fields: fields, path: []}, acc -> MapSet.union(acc, argument_fields(fields))
      %FieldGroup{path: [name]}, acc -> MapSet.put(acc, name)
      %Field{name: name, path: []}, acc -> MapSet.put(acc, name)
      %Field{path: [name]}, acc -> MapSet.put(acc, name)
      _, acc -> acc
    end)
  end
end
