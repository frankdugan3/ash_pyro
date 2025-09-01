defmodule AshPyro.DataTable.Column do
  @moduledoc ~s'''
  The configuration of a data table column in `AshPyro`.

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

  use AshPyro.Dsl.Entity,
    name: :column,
    args: [:name],
    describe:
      "Declare non-default behavior for a specific data table column in the `AshPyro.Dsl` extension.",
    # quokka:sort
    schema: [
      cell_class: [
        doc: "Customize cell class.",
        type: AshPyro.Dsl.Type.css_class()
      ],
      description: [
        doc: "Description of column.",
        type: AshPyro.Dsl.Type.inheritable(:string)
      ],
      header_class: [
        doc: "Customize header class.",
        type: AshPyro.Dsl.Type.css_class()
      ],
      keyset_sortable?: [
        default: true,
        doc:
          "Enable keyset-paged sorting. Note: If technically unsortable, automatically set to false.",
        type: :boolean
      ],
      label: [
        doc: "The label of the column (defaults to capitalized name).",
        type: :string
      ],
      name: [
        doc: "The name of the column.",
        required: true,
        type: :atom
      ],
      render_cell_data: [
        default: &__MODULE__.render_cell_data/1,
        type: AshPyro.Dsl.Type.render_fn()
      ],
      # resource_field_type: [
      #   private?: true,
      #   type:
      #     {:one_of,
      #      [
      #        :attribute,
      #        :calculation,
      #        :aggregate,
      #        :has_one,
      #        :belongs_to,
      #        :has_many,
      #        :many_to_many
      #      ]}
      # ],
      sortable?: [
        default: true,
        doc:
          "Enable unpaged and offset-paged sorting. Note: If technically unsortable, automatically set to false.",
        type: :boolean
      ],
      source: [
        doc: "Source path for data (defaults to name).",
        type: {:list, :atom}
      ],
      type: [
        default: :default,
        doc: "The type of the the column.",
        type: {:one_of, [:default]}
      ]
    ],
    transform: {__MODULE__, :__set_defaults__, []}

  alias AshPyro.Dsl.Transformers

  @doc """
  The default render function for row cell data.
  """
  def render_cell_data(%{col: %{name: name, type: :default}, row: row}) do
    Map.get(row, name)
  end

  @doc false
  def __set_defaults__(column) do
    {:ok,
     column
     |> Map.update!(:source, fn
       nil -> List.wrap(column.name)
       source -> source
     end)
     |> Map.update!(:label, fn
       nil -> Transformers.default_label(column.name)
       label -> label
     end)}
  end
end
