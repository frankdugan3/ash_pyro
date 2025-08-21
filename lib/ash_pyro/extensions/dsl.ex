defmodule AshPyro.Extensions.Dsl do
  @moduledoc false
  use Spark.Dsl.Extension,
    sections: [
      %Spark.Dsl.Section{
        describe: "Configure Pyro for a given resource",
        name: :pyro,
        schema: [
          resource: [
            type: {:spark, Ash.Resource},
            doc: "The Ash resource",
            required?: true
          ]
        ],
        sections: AshPyro.Extensions.Dsl.Sections.schema(),
        top_level?: true
      }
    ],
    transformers: [
      AshPyro.Extensions.Transformers.MergeDataTableActions,
      AshPyro.Extensions.Transformers.MergeFormActions,
      AshPyro.Extensions.Transformers.MergePages
    ],
    verifiers: [
      # AshPyro.Extensions.Verifiers.DataTableActions
      # AshPyro.Extensions.Verifiers.FormActions
      # AshPyro.Extensions.Verifiers.Pages
    ]
end
