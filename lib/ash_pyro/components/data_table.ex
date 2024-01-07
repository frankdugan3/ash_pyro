defmodule AshPyro.Components.DataTable do
  @moduledoc """
  A component that auto-renders forms for Ash resources.
  """

  use AshPyro.Component

  import Pyro.Components.DataTable, only: [data_table: 1]

  @doc """
  Renders a data table.
  """

  attr :overrides, :list, default: nil, doc: @overrides_attr_doc
  attr :id, :string, required: true
  attr :config, AshPyro.Extensions.Resource.DataTable.Action, required: true
  attr :rows, :list, required: true
  attr :sort, :list, required: true
  attr :display, :list, required: true
  attr :filter, :list, required: true
  attr :resource, :atom, required: true, doc: "the resource of the data table"
  attr :actor, :map, default: nil, doc: "the actor to be passed to actions"
  attr :tz, :string, default: "Etc/UTC", doc: "timezone"
  attr :class, :css_classes, overridable: true

  def ash_data_table(assigns) do
    assigns = assign_overridables(assigns)

    ~H"""
    <.data_table id={@id} rows={@rows} sort={@sort} class={ash_class(@class, assigns)}>
      <:col
        :let={row}
        :for={col <- display_columns(@config.columns, @display)}
        label={col.label}
        sort_key={if col.sortable?, do: col.name}
        class={ash_class(col.class, col)}
        cell_class={ash_class(col.cell_class, col)}
      >
        <%= apply(col.render_cell, [%{row: row, col: col}]) %>
      </:col>
    </.data_table>
    """
  end

  defp display_columns(columns, display) do
    Enum.map(display, fn name -> Enum.find(columns, fn column -> column.name == name end) end)
  end
end
