defmodule PyroManiac.Dsl.Verifiers.DataTable.NoDuplicateColumns do
  @moduledoc """
  Ensures no columns are duplicated for a given action in a data table.
  """
  use PyroManiac.Dsl.Verifiers

  alias PyroManiac.DataTable.{Action, Column}

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)

    for %Action{} = action <- Verifier.get_entities(dsl, [:data_table]) do
      for {key, count} <- count_columns(action.columns) do
        case count do
          1 ->
            :ok

          count ->
            raise DslError.exception(
                    module: module,
                    path: [:data_table, :action, action.name],
                    message: "#{count} columns define #{inspect(key)}"
                  )
        end
      end
    end

    :ok
  end

  defp count_columns(columns, count \\ %{}) do
    Enum.reduce(columns, count, fn
      %Column{name: name}, acc ->
        Map.update(acc, name, 1, &(&1 + 1))
    end)
  end
end
