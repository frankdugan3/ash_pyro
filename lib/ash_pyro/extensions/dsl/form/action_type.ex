defmodule AshPyro.Extensions.Dsl.Form.ActionType do
  @moduledoc """
  A form for action(s) of a given type in the `AshPyro.Extensions.Resource` extension.
  """

  use AshPyro.Extensions.Dsl.Schema

  alias AshPyro.Extensions.Dsl.Form.Field
  alias AshPyro.Extensions.Dsl.Form.FieldGroup
  alias Spark.Dsl.Entity

  @type t :: %__MODULE__{}
  defstruct [:class, :fields, :name]

  @action_types {:one_of, [:create, :update]}

  @schema [
    name: [
      type: {:or, [@action_types, {:list, @action_types}]},
      required: true,
      doc: "The action type(s) for this form."
    ],
    class: [
      type: css_class_schema_type(),
      required: false,
      doc: "Customize form classes."
    ]
  ]

  @entity %Entity{
    args: [:name],
    describe:
      "Configure default form appearance for actions of type(s). Will be ignored by actions configured explicitly.",
    entities: [
      fields: [Field.entity(), FieldGroup.entity()]
    ],
    name: :action_type,
    schema: @schema,
    target: __MODULE__
  }

  @doc false
  def entity, do: @entity
end
