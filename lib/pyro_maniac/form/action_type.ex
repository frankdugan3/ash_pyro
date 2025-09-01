defmodule PyroManiac.Form.ActionType do
  @moduledoc """
  A form for action(s) of a given type in `PyroManiac`.
  """

  use PyroManiac.Dsl.Entity,
    name: :action_type,
    args: [:name],
    describe:
      "Configure default form appearance for actions of type(s). Will be ignored by actions configured explicitly.",
    entities: [
      fields: [PyroManiac.Form.Field, PyroManiac.Form.FieldGroup, PyroManiac.Form.Step]
    ],
    # quokka:sort
    schema: [
      class: [
        doc: "Customize form classes.",
        type: PyroManiac.Dsl.Type.css_class()
      ],
      name: [
        doc: "The action type(s) for this form.",
        required: true,
        # quokka:sort
        type: {:wrap_list, {:one_of, [:create, :update]}}
      ]
    ]
end
