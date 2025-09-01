defmodule AshPyro.Dsl.Verifiers.Form.AllFieldsInAction do
  @moduledoc """
  Ensures all form fields for each action refer to an accepted attribute or argument.
  """

  use AshPyro.Dsl.Verifiers

  alias Ash.Resource.Info, as: ResourceInfo
  alias AshPyro.Form.{Action, FieldGroup, Field}

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)
    resource = Verifier.get_persisted(dsl, :resource, nil)

    for %Action{} = action <- Verifier.get_entities(dsl, [:form]) do
      resource_action = ResourceInfo.action(resource, action.name)

      inputs =
        MapSet.new(resource_action.accept ++ Enum.map(resource_action.arguments, & &1.name))

      for field <- fields(action.fields) do
        if !MapSet.member?(inputs, field) do
          raise DslError.exception(
                  module: module,
                  path: [:form, :action, action.name],
                  message:
                    "field #{inspect(field)} is not an accepted attribute or argument for this action"
                )
        end
      end
    end

    :ok
  end

  defp fields(fields, acc \\ nil) do
    Enum.reduce(fields, acc || MapSet.new(), fn
      %FieldGroup{fields: fields, path: []}, acc -> MapSet.union(acc, fields(fields))
      %FieldGroup{path: [name]}, acc -> MapSet.put(acc, name)
      %Field{name: name, path: []}, acc -> MapSet.put(acc, name)
      %Field{path: [name]}, acc -> MapSet.put(acc, name)
      _, acc -> acc
    end)
  end
end
