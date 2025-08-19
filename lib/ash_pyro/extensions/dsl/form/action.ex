defmodule AshPyro.Extensions.Dsl.Form.Action do
  @moduledoc """
  A form for action(s) in the `AshPyro.Extensions.Resource` extension.
  """
  use AshPyro.Extensions.Dsl.Schema

  alias AshPyro.Extensions.Dsl.Form.Field
  alias AshPyro.Extensions.Dsl.Form.FieldGroup
  alias Spark.Dsl.Entity

  @type t :: %__MODULE__{}
  defstruct [:class, :description, :fields, :label, :name]

  @schema [
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
      type: css_class_schema_type(),
      required: false,
      doc: "Customize form classes."
    ]
  ]

  @entity %Entity{
    args: [:name],
    describe: "Configure the appearance forms forms for specific action(s).",
    entities: [
      fields: [Field.entity(), FieldGroup.entity()]
    ],
    name: :action,
    schema: @schema,
    target: __MODULE__
  }

  @doc false
  def entity, do: @entity
end
