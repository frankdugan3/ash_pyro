defmodule AshPyro.Extensions.Resource do
  @moduledoc """
  An Ash resource extension providing declarative configuration of user interfaces.
  """
  use Spark.Dsl.Extension,
    sections: [
      %Spark.Dsl.Section{
        describe: "Configure pyro for a given resource",
        name: :pyro,
        sections: AshPyro.Extensions.Dsl.Sections.schema()
      }
    ],
    transformers: AshPyro.Extensions.Dsl.transformers(),
    verifiers: AshPyro.Extensions.Dsl.verifiers()
end
