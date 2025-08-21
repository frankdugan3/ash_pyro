defmodule AshPyro.Extensions.Dsl.LiveView.Page.Update do
  @moduledoc """
  An update type live_action for a LiveView page.
  """

  use AshPyro.Extensions.Dsl.Entity,
    args: [:path, :live_action, :action],
    describe: "Configure a update action for this resource.",
    name: :update,
    schema: [
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
        type: {:inheritable, :string},
        required: false,
        doc: "The label for this action (defaults to humanized live_action)."
      ],
      description: [
        type: {:inheritable, :string},
        required: false,
        doc: "The description for this action."
      ],
      class: [
        type: :css_class,
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
      ],
      parent_action: [type: :any, private?: true],
      create_actions: [type: :any, private?: true, default: []],
      list_actions: [type: :any, private?: true, default: []],
      show_actions: [type: :any, private?: true, default: []],
      update_actions: [type: :any, private?: true, default: []],
      destroy_actions: [type: :any, private?: true, default: []]
    ]
end
