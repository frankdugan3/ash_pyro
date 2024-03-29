defmodule AshPyro.Extensions.Resource.LiveView.Page.Update do
  @moduledoc """
  An update type live_action for a LiveView page.
  """

  use AshPyro.Extensions.Resource.Schema

  @type t :: %__MODULE__{}
  defstruct [
    # schema fields
    :path,
    :live_action,
    :action,
    :load_action,
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
      type: {:wrap_list, :string},
      required: true,
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
      doc: "The action to use to update the record."
    ],
    load_action: [
      type: :atom,
      required: false,
      doc: "The action to use to load the record."
    ],
    display_as: [
      type: {:one_of, [:form]},
      required: false,
      default: :form,
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
      default: "hero-pencil-square-solid",
      doc: "The icon to use for links/buttons."
    ]
  ]

  @doc false
  def schema, do: @schema
end
