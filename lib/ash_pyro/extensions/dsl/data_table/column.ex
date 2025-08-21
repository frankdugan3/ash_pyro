defmodule AshPyro.Extensions.Dsl.DataTable.Column do
  @moduledoc ~s'''
  The configuration of a data table column in the `AshPyro.Extensions.Resource` extension.

  By default, the `tbody` cell will be rendered with `render_cell/1`. You can also change the `:type` option to specify special kinds of rendering.

  For bespoke rendering needs, you can provide a custom component inline or as a function capture:

  ```elixir
  import Phoenix.Component, only: [sigil_H: 2]
  column :code do
    class "whitespace-nowrap"
    render_cell fn assigns ->
      ~H"""
      <PyroComponents.Core.icon name="hero-rocket-launch" />
      <%= Map.get(@row, @col[:name]) %>
      """
    end
  end
  ```
  '''

  use AshPyro.Extensions.Dsl.Entity,
    args: [:name],
    describe:
      "Declare non-default behavior for a specific data table column in the `AshPyro.Extensions.Dsl` extension.",
    name: :column,
    schema: [
      cell_class: [type: :css_class, required: false, doc: "Customize cell class."],
      class: [type: :css_class, required: false, doc: "Customize header class."],
      description: [
        type: :string,
        required: false,
        doc: "Override the default extracted description."
      ],
      label: [
        type: :string,
        required: false,
        doc: "The label of the column (defaults to capitalized name)."
      ],
      name: [type: :atom, required: true, doc: "The name of the column."],
      path: [
        type: {:list, :atom},
        required: false,
        doc: "Append to the root path (nested paths are appended)."
      ],
      render_cell: [type: {:fun, 1}, default: &__MODULE__.render_cell/1],
      sortable?: [
        type: :boolean,
        required: false,
        default: true,
        doc:
          "Set to false to disable sorting. Note: If it it is not technically sortable, it will automatically be set to false."
      ],
      type: [
        type: {:one_of, [:default]},
        required: false,
        doc: "The type of the the column.",
        default: :default
      ],
      resource_field_type: [
        type:
          {:one_of,
           [
             :attribute,
             :calculation,
             :aggregate,
             :has_one,
             :belongs_to,
             :has_many,
             :many_to_many
           ]},
        private?: true
      ]
    ]

  def render_cell(%{col: %{name: name, type: :default}, row: row}) do
    Map.get(row, name)
  end
end
