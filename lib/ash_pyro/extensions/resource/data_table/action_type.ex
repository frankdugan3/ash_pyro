defmodule AshPyro.Extensions.Resource.DataTable.ActionType do
  @moduledoc """
  A data table for action(s) of a given type in the `AshPyro.Extensions.Resource` extension.
  """
  use AshPyro.Extensions.Resource.Schema

  @type t :: %__MODULE__{
          class: Schema.css_class(),
          columns: [AshPyro.Extensions.Resource.DataTable.Column],
          default_display: [atom()],
          default_sort: Schema.sort(),
          exclude: [atom()],
          name: atom()
        }
  defstruct [
    :class,
    :columns,
    :default_display,
    :default_sort,
    :exclude,
    :name
  ]

  @action_types {:one_of, [:read]}

  @schema [
    class: [
      type: css_class_schema_type(),
      required: false,
      doc: "Customize data table classes."
    ],
    default_display: [
      required: false,
      type: {:list, :atom},
      doc: "The columns to display by default.",
      default: []
    ],
    default_sort: [
      required: false,
      type: sort_schema_type(),
      doc: "The columns to sort on by default.",
      default: nil
    ],
    exclude: [
      required: false,
      type: {:list, :atom},
      doc: "The fields to exclude from columns.",
      default: []
    ],
    exclude: [
      required: false,
      type: {:list, :atom},
      doc: "The fields to exclude from columns.",
      default: []
    ],
    name: [
      type: {:or, [@action_types, {:list, @action_types}]},
      required: true,
      doc: "The action type(s) for this data table."
    ]
  ]

  @doc false
  def schema, do: @schema
end
