defmodule AshPyro.Extensions.Dsl.DataTable.ActionType do
  @moduledoc """
  A data table for action(s) of a given type in the `AshPyro.Extensions.Resource` extension.
  """
  use AshPyro.Extensions.Dsl.Entity,
    args: [:name],
    describe:
      "Configure the default data table appearance for actions of type(s). Will be ignored by actions configured explicitly.",
    entities: [
      columns: [AshPyro.Extensions.Dsl.DataTable.Column]
    ],
    name: :action_type,
    schema: [
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
      ],
      name: [
        type: {:wrap_list, {:one_of, [:read]}},
        required: true,
        doc: "The action type(s) for this data table."
      ]
    ]
end
