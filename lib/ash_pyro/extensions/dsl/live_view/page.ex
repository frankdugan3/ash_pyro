defmodule AshPyro.Extensions.Dsl.LiveView.Page do
  @moduledoc """
  A LiveView page.
  """
  use AshPyro.Extensions.Dsl.Schema

  alias Spark.Dsl.Entity

  @type t :: %__MODULE__{
          __identifier__: any(),
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
    :class,
    :keep_live?,
    :live_actions,
    :name,
    :path,
    :route_helper,
    :view_as
  ]

  @schema [
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
    ]
  ]

  @entity %Entity{
    args: [:path, :name],
    describe: "Configure a page for this resource.",
    entities: [
      live_actions: [
        __MODULE__.Create.entity(),
        __MODULE__.List.entity(),
        __MODULE__.Show.entity(),
        __MODULE__.Update.entity()
      ]
    ],
    identifier: :name,
    name: :page,
    schema: @schema,
    target: __MODULE__
  }
  @doc false
  def entity, do: @entity
end
