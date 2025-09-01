defmodule AshPyro.Form.ActionType do
  @moduledoc """
  A form for action(s) of a given type in `AshPyro`.
  """

  use AshPyro.Dsl.Entity,
    name: :action_type,
    args: [:name],
    describe:
      "Configure default form appearance for actions of type(s). Will be ignored by actions configured explicitly.",
    entities: [
      fields: [AshPyro.Form.Field, AshPyro.Form.FieldGroup, AshPyro.Form.Step]
    ],
    # quokka:sort
    schema: [
      class: [
        doc: "Customize form classes.",
        type: AshPyro.Dsl.Type.css_class()
      ],
      name: [
        doc: "The action type(s) for this form.",
        required: true,
        # quokka:sort
        type: {:wrap_list, {:one_of, [:create, :update]}}
      ]
    ]
end
