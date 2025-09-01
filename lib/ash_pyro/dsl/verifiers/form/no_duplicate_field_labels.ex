defmodule AshPyro.Dsl.Verifiers.Form.NoDuplicateFieldLabels do
  @moduledoc """
  Ensures no duplicate field labels exist in each action within the same path.
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
                    message: "#{count} fields use the label #{key}"
                  )
        end
      end
    end

    :ok
  end

  defp count_fields(fields, count \\ %{}) do
    Enum.reduce(fields, count, fn
      %FieldGroup{fields: fields, label: label, path: path}, acc ->
        count_fields(fields, Map.update(acc, key_for_path(label, path), 1, &(&1 + 1)))

      %Field{label: label, path: path}, acc ->
        Map.update(acc, key_for_path(label, path), 1, &(&1 + 1))
    end)
  end

  defp key_for_path(label, []), do: inspect(label)
  defp key_for_path(label, path), do: inspect(path) <> " -> " <> inspect(label)
end
