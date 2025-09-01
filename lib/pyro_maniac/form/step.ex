defmodule PyroManiac.Form.Step do
  @moduledoc """
  A step for wizard forms.
  """

  use PyroManiac.Dsl.Entity,
    name: :step,
    args: [:name],
    describe: "Configure a form step in the `PyroManiac.Dsl` extension.",
    entities: [fields: [PyroManiac.Form.Field, PyroManiac.Form.FieldGroup]],
    # quokka:sort
    schema: [
      class: [
        doc: "Customize class.",
        type: PyroManiac.Dsl.Type.css_class()
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
