defmodule AshPyro.Form.Step do
  @moduledoc """
  A step for wizard forms.
  """

  use AshPyro.Dsl.Entity,
    name: :step,
    args: [:name],
    describe: "Configure a form step in the `AshPyro.Dsl` extension.",
    entities: [fields: [AshPyro.Form.Field, AshPyro.Form.FieldGroup]],
    # quokka:sort
    schema: [
      class: [
        doc: "Customize class.",
        type: AshPyro.Dsl.Type.css_class()
      ],
      label: [
        doc: "The label of this step (defaults to capitalized name).",
        type: :string
      ],
      name: [
        doc: "The name of the step,",
        required: true,
        type: :atom
      ]
    ]
end
