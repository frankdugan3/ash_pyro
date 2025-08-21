defmodule AshPyro.Extensions.Dsl.Form.FieldGroup do
  @moduledoc """
  A group of form fields in the `AshPyro.Extensions.Resource` extension.
  """

  use AshPyro.Extensions.Dsl.Entity,
    args: [:name],
    describe:
      "Configure the appearance of form field groups in the `AshPyro.Extensions.Dsl` extension.",
    entities: [
      fields: [AshPyro.Extensions.Dsl.Form.Field]
    ],
    name: :field_group,
    recursive_as: :fields,
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "The name of the field group."
      ],
      label: [
        type: :string,
        required: false,
        doc: "The label of this group (defaults to capitalized name)."
      ],
      class: [
        type: :css_class,
        required: false,
        doc: "Customize class."
      ],
      path: [
        type: {:list, :atom},
        required: false,
        doc: "Append to the root path (nested paths are appended)."
      ]
    ]
end
