defmodule AshPyro.Helpers do
  @moduledoc """
  Shared helpers used to implement your own AshPyro components.
  """

  @doc """
  AshPyro DSL allows component classes to be functions accepting `assigns`. This helper function simplifies handling that case in components:

  ```elixir
  <:col
    :for={col <- display_columns(@config.columns, @display)}
    class={ash_class(col.class, col)}>
  ```
  """
  def ash_class(fun, assigns) when is_function(fun, 1), do: fun.(assigns)

  def ash_class(class, _assigns), do: class
end
