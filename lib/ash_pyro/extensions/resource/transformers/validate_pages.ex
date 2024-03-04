defmodule AshPyro.Extensions.Resource.Verifiers.Pages do
  @moduledoc false

  use AshPyro.Extensions.Resource.Verifiers

  # alias AshPyro.Extensions.Resource.Pages
  # alias Spark.Dsl.Extension

  @impl true
  def verify(_dsl_state) do
    # TODO: Validate page paths don't have different params at the same depth for the same path group.
    :ok
  end
end
