defmodule AshPyro.Extensions.Dsl.Form.ActionType do
  @moduledoc """
  A form for action(s) of a given type in the `AshPyro.Extensions.Resource` extension.
  """

  use AshPyro.Extensions.Dsl.Entity,
    args: [:name],
    describe:
      "Configure default form appearance for actions of type(s). Will be ignored by actions configured explicitly.",
    entities: [
      fields: [AshPyro.Extensions.Dsl.Form.Field, AshPyro.Extensions.Dsl.Form.FieldGroup]
    ],
    name: :action_type,
    schema: [
      name: [
        type: {:wrap_list, {:one_of, [:create, :update]}},
        required: true,
        doc: "The action type(s) for this form."
      ],
      class: [
        type: :css_class,
        required: false,
        doc: "Customize form classes."
      ]
    ]
end
