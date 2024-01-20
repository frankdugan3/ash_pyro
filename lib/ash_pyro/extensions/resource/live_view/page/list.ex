defmodule AshPyro.Extensions.Resource.LiveView.Page.List do
  @moduledoc """
  A LiveView page.
  """

  use AshPyro.Extensions.Resource.Schema

  @type t :: %__MODULE__{}
  defstruct [
    :path,
    :live_action,
    :action,
    :display_as,
    :label,
    :description,
    :class,
    :pagination,
    :default_limit
  ]

  @schema [
    path: [
      required: true,
      type: :string,
      doc: "The route path for this action."
    ],
    live_action: [
      type: :atom,
      required: true,
      doc: "The live action for this action."
    ],
    action: [
      type: :atom,
      required: true,
      doc: "The action to use to load the records."
    ],
    display_as: [
      type: {:one_of, [:data_table, :card_grid]},
      required: false,
      default: :data_table,
      doc: "How to display the action."
    ],
    label: [
      type: inheritable_schema_type(),
      required: false,
      doc: "The label for this action (defaults to humanized live_action)."
    ],
    description: [
      type: inheritable_schema_type(),
      required: false,
      doc: "The description for this action."
    ],
    class: [
      type: css_class_schema_type(),
      required: false,
      doc: "Customize action classes."
    ],
    pagination: [
      type: pagination_schema_type(),
      required: false,
      doc: "The pagination type (defaults to `:offset` if available)."
    ],
    default_limit: [
      type: :integer,
      required: false,
      doc: "The default pagination limit (defaults to the resource's `default_limit`, falling back to `max_page_size`)."
    ]
  ]

  @doc false
  def schema, do: @schema
end
