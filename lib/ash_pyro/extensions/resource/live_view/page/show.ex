defmodule AshPyro.Extensions.Resource.LiveView.Page.Show do
  @moduledoc """
  A show type live_action for a LiveView page.
  """

  use AshPyro.Extensions.Resource.Schema

  @type t :: %__MODULE__{}
  defstruct [
    # schema fields
    :path,
    :live_action,
    :action,
    :display_as,
    :label,
    :description,
    :class,
    :identity,
    :icon_name,
    # meta fields
    parent_action: nil,
    create_actions: [],
    list_actions: [],
    show_actions: [],
    update_actions: [],
    destroy_actions: []
  ]

  @schema [
    path: [
      required: true,
      type: {:wrap_list, :string},
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
      doc: "The action to use to load the record."
    ],
    display_as: [
      type: {:one_of, [:card]},
      required: false,
      default: :card,
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
    identity: [
      required: false,
      type: {:wrap_list, :atom},
      default: :id,
      doc: "The identity used to load the record."
    ],
    icon_name: [
      type: :string,
      required: false,
      default: "hero-eye-solid",
      doc: "The icon to use for links/buttons."
    ]
  ]

  @doc false
  def schema, do: @schema
end
