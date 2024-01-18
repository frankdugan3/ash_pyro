defmodule AshPyro.LiveComponent do
  @moduledoc ~S"""
  This is basically a wrapper around `Pyro.LiveComponent`, but it uses `AshPyro.Component` instead of `Pyro.Component` to enable AshPyro's extended features.
  """

  @doc false
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      import Phoenix.LiveView
      @behaviour Phoenix.LiveComponent
      @before_compile Phoenix.LiveView.Renderer

      # AshPyro.Component must come last so its @before_compile runs last
      use AshPyro.Component, opts

      @doc false
      def __live__, do: %{kind: :component, layout: false}
    end
  end
end
