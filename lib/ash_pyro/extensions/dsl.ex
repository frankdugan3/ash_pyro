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
      AshPyro.Extensions.Resource.Transformers.MergeDataTableActions,
      AshPyro.Extensions.Resource.Transformers.MergeFormActions,
      AshPyro.Extensions.Resource.Transformers.MergePages
    ],
    verifiers: [
      # AshPyro.Extensions.Resource.Verifiers.DataTableActions
      # AshPyro.Extensions.Resource.Verifiers.FormActions
      # AshPyro.Extensions.Resource.Verifiers.Pages
    ]
end
