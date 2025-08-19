defmodule AshPyro.Extensions.Dsl.Form.FieldGroup do
  @moduledoc """
  A group of form fields in the `AshPyro.Extensions.Resource` extension.
  """

  use AshPyro.Extensions.Dsl.Schema

  alias AshPyro.Extensions.Dsl.Form.Field
  alias Spark.Dsl.Entity

  defstruct [:class, :fields, :label, :name, :path]

  @type t :: %__MODULE__{
          class: String.t(),
          fields: [Field.t()],
          label: String.t(),
          name: String.t(),
          path: [atom()]
        }

  @schema [
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
      type: css_class_schema_type(),
      required: false,
      doc: "Customize class."
    ],
    path: [
      type: {:list, :atom},
      required: false,
      doc: "Append to the root path (nested paths are appended)."
    ]
  ]

  @entity %Entity{
    args: [:name],
    describe:
      "Configure the appearance of form field groups in the `AshPyro.Extensions.Dsl` extension.",
    entities: [
      fields: [Field.entity()]
    ],
    name: :field_group,
    recursive_as: :fields,
    schema: @schema,
    target: __MODULE__
  }

  @doc false
  def entity, do: @entity
end
