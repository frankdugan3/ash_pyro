defmodule AshPyro.Extensions.Dsl.LiveView.Page do
  @moduledoc """
  A LiveView page.
  """
  use AshPyro.Extensions.Dsl.Entity,
    args: [:path, :name],
    describe: "Configure a page for this resource.",
    entities: [
      live_actions: [
        __MODULE__.Create,
        __MODULE__.List,
        __MODULE__.Show,
        __MODULE__.Update
      ]
    ],
    identifier: :name,
    name: :page,
    schema: [
      class: [
        type: :css_class,
        required: false,
        doc: "Customize page classes."
      ],
      keep_live?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Subscribe to resource updates and keep the view up to date."
      ],
      name: [
        type: :atom,
        required: true,
        doc: "The live action for this page."
      ],
      path: [
        required: true,
        type: {:wrap_list, :string},
        doc: "The route path for this page."
      ],
      route_helper: [
        type: :atom,
        required: false,
        doc: "The route helper name to be generated. Defaults to [name]_path."
      ],
      view_as: [
        type: {:one_of, [:list_and_modal, :show_and_modal, :individual]},
        required: false,
        default: :list_and_modal,
        doc: """
        The view style of the page:
          - `:list_and_modal` - Always list view, show/create/edit in a modal
          - `:show_and_modal` - List view for list actions, show as a dedicated view, create/edit in a modal on show
          - `:individual` - All actions are a dedicated view
        """
      ],
      __identifier__: [
        type: :any,
        private?: true
      ]
    ]
end
