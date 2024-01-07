defmodule AshPyro.Extensions.Resource.LiveView.Page do
  @moduledoc """
  A LiveView page.
  """
  use AshPyro.Extensions.Resource.Schema

  @type t :: %__MODULE__{
          __identifier__: any(),
          api: atom(),
          class: Schema.css_class(),
          keep_live?: boolean(),
          live_actions:
            list(
              __MODULE__.Create.t()
              | __MODULE__.List.t()
              | __MODULE__.Show.t()
              | __MODULE__.Update.t()
            ),
          name: atom(),
          path: list(atom()),
          route_helper: function(),
          view_as: :list_and_modal | :show_and_modal | :individual
        }
  defstruct [
    :__identifier__,
    :api,
    :class,
    :keep_live?,
    :live_actions,
    :name,
    :path,
    :route_helper,
    :view_as
  ]

  @schema [
    api: [
      type: :atom,
      required: true,
      doc: "The API for routes on this page (can also specify per-route/per-action)."
    ],
    class: [
      type: css_class_schema_type(),
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
      type: :string,
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
    ]
  ]

  @doc false
  def schema, do: @schema
end
