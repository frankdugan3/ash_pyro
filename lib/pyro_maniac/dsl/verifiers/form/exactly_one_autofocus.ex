defmodule PyroManiac.Dsl.Verifiers.Form.ExactlyOneAutofocus do
  @moduledoc """
  Ensures each action's form has exactly one autofocus field.
  """

  use PyroManiac.Dsl.Verifiers

  alias PyroManiac.Form.{Action, Field, FieldGroup}

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)

    for %Action{} = action <- Verifier.get_entities(dsl, [:form]) do
      if count_autofocus(action.fields) != 1 do
        raise DslError.exception(
                module: module,
                path: [:form, :action, action.name],
                message: "exactly one field must have autofocus"
              )
      end
    end

    :ok
  end

  defp count_autofocus(fields, total \\ 0) do
    Enum.reduce(fields, total, fn
      %FieldGroup{fields: fields}, acc -> count_autofocus(fields, acc)
      %Field{autofocus: true}, acc -> acc + 1
      _, acc -> acc
    end)
  end
end
