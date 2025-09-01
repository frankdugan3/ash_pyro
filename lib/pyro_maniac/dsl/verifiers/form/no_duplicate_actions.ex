defmodule PyroManiac.Dsl.Verifiers.Form.NoDuplicateActions do
  @moduledoc """
  Ensures that forms have no duplicated action definitions or duplicate labels for actions.
  """

  use PyroManiac.Dsl.Verifiers

  alias PyroManiac.Form.Action

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)

    actions =
      for %Action{} = action <- Verifier.get_entities(dsl, [:form]) do
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
                  path: [:form, :action],
                  message: error_msg.(value, count)
                )
        end
      end)
    end

    :ok
  end
end
