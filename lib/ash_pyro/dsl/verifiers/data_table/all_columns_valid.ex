defmodule AshPyro.Dsl.Verifiers.DataTable.AllColumnsValid do
  @moduledoc """
  Ensure all columns in earch action are valid fields or relationship paths.
  """
  use AshPyro.Dsl.Verifiers

  alias Ash.Resource.Info, as: ResourceInfo
  alias AshPyro.DataTable.{Action, Column}

  @impl true
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module, nil)
    resource = Verifier.get_persisted(dsl, :resource, nil)

    for %Action{} = action <- Verifier.get_entities(dsl, [:data_table]) do
      for %Column{} = column <- action.columns do
        {name, path} = List.pop_at(column.source, -1)

        source_resource = AshPyro.Info.resource_by_path(resource, path)
        field = ResourceInfo.field(source_resource, name)

        if !field do
          raise DslError.exception(
                  module: module,
                  path: [:data_table, :action, action.name, :columns],
                  message:
                    "column #{inspect(column.name)} source #{inspect(path)} -> #{inspect(name)} does not exist on #{source_resource}"
                )
        end

        if !field.public? do
          raise DslError.exception(
                  module: module,
                  path: [:data_table, :action, action.name, :columns],
                  message:
                    "column #{inspect(column.name)} source #{inspect(path)} -> #{inspect(name)} is private on #{source_resource}"
                )
        end
      end
    end

    :ok
  end
end
