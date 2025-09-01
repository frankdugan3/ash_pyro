defmodule AshPyro.Form.Action do
  @moduledoc """
  A form configuration for an Ash resource action.
  """
  use AshPyro.Dsl.Entity,
    name: :action,
    args: [:name],
    describe: "Configure the appearance forms forms for specific action(s).",
    entities: [
      fields: [AshPyro.Form.Field, AshPyro.Form.FieldGroup, AshPyro.Form.Step]
    ],
    # quokka:sort
    schema: [
      class: [
        doc: "Customize form classes.",
        type: AshPyro.Dsl.Type.css_class()
      ],
      description: [
        doc: "The description for this form (defaults to action's description).",
        type: :string
      ],
      label: [
        doc: "The label for this form (defaults to capitalized name).",
        type: :string
      ],
      name: [
        doc: "The action name(s) for this form.",
        required: true,
        type: {:wrap_list, :atom}
      ]
    ]
end
