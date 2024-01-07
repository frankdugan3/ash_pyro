defmodule AshPyro.Extensions.Resource.Form.ActionType do
  @moduledoc """
  A form for action(s) of a given type in the `AshPyro.Extensions.Resource` extension.
  """

  use AshPyro.Extensions.Resource.Schema

  @type t :: %__MODULE__{}
  defstruct [:name, :class, :fields]

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

  @doc false
  def schema, do: @schema
end
