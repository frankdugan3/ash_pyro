defmodule AshPyro do
  @moduledoc """
  A declarative configuration of user interfaces for Ash resources.
  """
  use Spark.Dsl,
    default_extensions: [
      extensions: [AshPyro.Extensions.Dsl]
    ]
end
