defmodule AshPyro.Extensions.Dsl.DataTable.Action do
  @moduledoc """
  A data table for action(s) in the `AshPyro.Extensions.Resource` extension.
  """
  use AshPyro.Extensions.Dsl.Entity,
    args: [:name],
    describe: "Configure the appearance of the data table for specific action(s).",
    entities: [
      columns: [AshPyro.Extensions.Dsl.DataTable.Column]
    ],
    name: :action,
    schema: [
      name: [
        type: {:wrap_list, :atom},
        required: true,
        doc: "The action name(s) for this data table."
      ],
      label: [
        type: :string,
        required: false,
        doc: "The label for this data table (defaults to capitalized name)."
      ],
      description: [
        type: :string,
        required: false,
        doc: "The description for this data table (defaults to action's description)."
      ],
      class: [
        type: :css_class,
        required: false,
        doc: "Customize data table classes."
      ],
      default_display: [
        required: false,
        type: {:list, :atom},
        doc: "The columns to display by default.",
        default: []
      ],
      default_sort: [
        required: false,
        type: :sort,
        doc: "The columns to sort on by default.",
        default: nil
      ],
      exclude: [
        required: false,
        type: {:list, :atom},
        doc: "The fields to exclude from columns.",
        default: []
      ]
    ]
end
