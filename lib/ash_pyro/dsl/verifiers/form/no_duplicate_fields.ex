defmodule AshPyro.Dsl.Verifiers.Form.NoDuplicateFields do
  @moduledoc """
  Ensures no duplicate fields exist in each action.
  """

  use AshPyro.Dsl.Verifiers

  alias AshPyro.Form.{Action, FieldGroup, Field}

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)

    for %Action{} = action <- Verifier.get_entities(dsl, [:form]) do
      for {key, count} <- count_fields(action.fields) do
        case count do
          1 ->
            :ok

          count ->
            raise DslError.exception(
                    module: module,
                    path: [:form, :action, action.name],
                    message: "#{count} fields define #{key}"
                  )
        end
      end
    end

    :ok
  end

  defp count_fields(fields, count \\ %{}) do
    Enum.reduce(fields, count, fn
      %FieldGroup{fields: fields}, acc ->
        count_fields(fields, acc)

      %Field{name: name, path: []}, acc ->
        Map.update(acc, inspect(name), 1, &(&1 + 1))

      %Field{name: name, path: path}, acc ->
        Map.update(acc, Enum.join(path ++ [name], "."), 1, &(&1 + 1))
    end)
  end
end
