defmodule AshPyro.Form.FieldGroup do
  @moduledoc """
  A group of form fields in `AshPyro`.
  """

  use AshPyro.Dsl.Entity,
    name: :field_group,
    args: [:label],
    describe: "Configure the appearance of form field groups in the `AshPyro.Dsl` extension.",
    recursive_as: :fields,
    entities: [fields: [AshPyro.Form.Field]],
    # quokka:sort
    schema: [
      class: [
        doc: "Customize class.",
        type: AshPyro.Dsl.Type.css_class()
      ],
      label: [
        doc: "The label of this group (defaults to capitalized name).",
        type: :string
      ],
      path: [
        default: [],
        doc: "Append to the root path (nested paths are appended).",
        type: {:list, :atom}
      ]
    ]
end
