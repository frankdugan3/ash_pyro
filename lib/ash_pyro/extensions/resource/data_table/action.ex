defmodule AshPyro.Extensions.Resource.DataTable.Action do
  @moduledoc """
  A data table for action(s) in the `AshPyro.Extensions.Resource` extension.
  """
  use AshPyro.Extensions.Resource.Schema

  @type t :: %__MODULE__{
          class: Schema.css_class(),
          columns: [AshPyro.Extensions.Resource.DataTable.Column],
          default_display: [atom()],
          default_sort: Schema.sort(),
          description: binary(),
          exclude: [atom()],
          label: binary(),
          name: atom()
        }
  defstruct [
    :class,
    :columns,
    :default_display,
    :default_sort,
    :description,
    :exclude,
    :label,
    :name
  ]

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
    description: [
      type: :string,
      required: false,
      doc: "The description for this data table (defaults to action's description)."
    ],
    name: [
      type: {:wrap_list, :atom},
      required: true,
      doc: "The action name(s) for this data table."
    ],
    label: [
      type: :string,
      required: false,
      doc: "The label for this data table (defaults to capitalized name)."
    ]
  ]

  @doc false
  def schema, do: @schema
end
