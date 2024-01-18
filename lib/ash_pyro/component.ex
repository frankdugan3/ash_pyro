defmodule AshPyro.Component do
  @moduledoc """
  Shared helpers used to build AshPyro components.
  """
  @doc """
  Render classes for an AshPyro component.
  """
  def ash_class(fun, assigns) when is_function(fun, 1), do: fun.(assigns)

  def ash_class(class, _assigns), do: class

  @doc """
  Wraps `use Pyro.Component`, also importing this module's helpers.
  """
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      use Pyro.Component, opts

      import unquote(__MODULE__)
    end
  end
end
