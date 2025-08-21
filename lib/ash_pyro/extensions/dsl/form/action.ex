defmodule AshPyro.Extensions.Dsl.Form.Action do
  @moduledoc """
  A form for action(s) in the `AshPyro.Extensions.Resource` extension.
  """
  use AshPyro.Extensions.Dsl.Entity,
    args: [:name],
    describe: "Configure the appearance forms forms for specific action(s).",
    entities: [
      fields: [AshPyro.Extensions.Dsl.Form.Field, AshPyro.Extensions.Dsl.Form.FieldGroup]
    ],
    name: :action,
    schema: [
      name: [
        type: {:wrap_list, :atom},
        required: true,
        doc: "The action name(s) for this form."
      ],
      label: [
        type: :string,
        required: false,
        doc: "The label for this form (defaults to capitalized name)."
      ],
      description: [
        type: :string,
        required: false,
        doc: "The description for this form (defaults to action's description)."
      ],
      class: [
        type: :css_class,
        required: false,
        doc: "Customize form classes."
      ]
    ]
end
