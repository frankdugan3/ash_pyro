defmodule AshPyro.Dsl.Verifiers.DataTable.NoDuplicateActions do
  @moduledoc false

  use AshPyro.Dsl.Verifiers

  alias AshPyro.DataTable.Action

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)

    actions =
      for %Action{} = action <- Verifier.get_entities(dsl, [:data_table]) do
        action
      end

    for {_field, extractor, error_msg} <- [
          {:name, & &1.name, fn name, count -> "#{inspect(name)} is defined #{count} times" end},
          {:label, & &1.label, fn label, count -> "#{count} actions share the label #{label}" end}
        ] do
      actions
      |> Enum.frequencies_by(extractor)
      |> Enum.each(fn {value, count} ->
        if count > 1 do
          raise DslError.exception(
                  module: module,
                  path: [:data_table, :action],
                  message: error_msg.(value, count)
                )
        end
      end)
    end

    :ok
  end
end
