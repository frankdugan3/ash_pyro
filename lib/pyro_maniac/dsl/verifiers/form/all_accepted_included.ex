defmodule PyroManiac.Dsl.Verifiers.Form.AllAcceptedIncluded do
  @moduledoc """
  Ensures all accepted attributes for each action is included in the form.
  """

  use PyroManiac.Dsl.Verifiers

  alias Ash.Resource.Info, as: ResourceInfo
  alias PyroManiac.Form.{Action, FieldGroup, Field}

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)
    resource = Verifier.get_persisted(dsl, :resource, nil)

    for %Action{name: name} = action <- Verifier.get_entities(dsl, [:form]) do
      fields = attribute_fields(action.fields)

      for accept <- ResourceInfo.action(resource, name).accept do
        if !MapSet.member?(fields, accept) do
          raise DslError.exception(
                  module: module,
                  path: [:form, :action, name],
                  message: "accepted attribute #{inspect(accept)} is not a form field"
                )
        end
      end
    end

    :ok
  end

  defp attribute_fields(fields) do
    Enum.reduce(fields, MapSet.new(), fn
      %FieldGroup{fields: fields, path: []}, acc -> MapSet.union(acc, attribute_fields(fields))
      %FieldGroup{path: [name]}, acc -> MapSet.put(acc, name)
      %Field{name: name, path: []}, acc -> MapSet.put(acc, name)
      %Field{path: [name]}, acc -> MapSet.put(acc, name)
      _, acc -> acc
    end)
  end
end
