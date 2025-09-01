defmodule AshPyro.DataTable.ActionType do
  @moduledoc """
  A data table for action(s) of a given type in `AshPyro`.
  """
  use AshPyro.Dsl.Entity,
    name: :action_type,
    args: [:name],
    describe:
      "Configure the default data table appearance for actions of type(s). Will be ignored by actions configured explicitly.",
    entities: [columns: [AshPyro.DataTable.Column]],
    # quokka:sort
    schema: [
      class: [
        doc: "Customize data table classes.",
        type: AshPyro.Dsl.Type.css_class()
      ],
      default_display: [
        doc: "The columns to display by default.",
        type: {:list, :atom}
      ],
      default_sort: [
        doc: "The columns to sort on by default.",
        type: AshPyro.Dsl.Type.sort()
      ],
      description: [
        doc: "The description for this data table.",
        type: AshPyro.Dsl.Type.inheritable(:string)
      ],
      exclude: [
        default: [],
        doc: "The fields to exclude from columns.",
        type: {:list, :atom}
      ],
      name: [
        doc: "The action type(s) for this data table.",
        required: true,
        type: {:wrap_list, {:one_of, [:read]}}
      ]
    ],
    transform: {AshPyro.DataTable.Action, :__set_defaults__, []}
end
