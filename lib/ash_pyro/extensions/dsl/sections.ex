defmodule AshPyro.Extensions.Dsl.Sections do
  @moduledoc false
  alias AshPyro.Extensions.Dsl.DataTable
  alias AshPyro.Extensions.Dsl.Form
  alias AshPyro.Extensions.Dsl.LiveView.Page
  alias Spark.Dsl.Section

  @schema [
    %Section{
      describe:
        "Configure the appearance of data tables in the `AshPyro.Extensions.Dsl` extension.",
      entities: [
        DataTable.Action.entity(),
        DataTable.ActionType.entity()
      ],
      name: :data_table,
      schema: [
        exclude: [
          required: false,
          type: {:list, :atom},
          doc: "The actions to exclude from data tables.",
          default: []
        ]
      ]
    },
    %Section{
      describe: "Configure the appearance of forms in the `AshPyro.Extensions.Dsl` extension.",
      entities: [
        Form.Action.entity(),
        Form.ActionType.entity()
      ],
      name: :form,
      schema: [
        exclude: [
          required: false,
          type: {:list, :atom},
          doc: "The actions to exclude from forms.",
          default: []
        ]
      ]
    },
    %Section{
      describe: "Configure LiveViews in the `AshPyro.Extensions.Dsl` extension.",
      entities: [Page.entity()],
      name: :live_view,
      schema: []
    }
  ]

  @doc false
  def schema, do: @schema
end
