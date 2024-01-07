defmodule AshPyro.LiveComponent do
  @moduledoc ~S'''
  This is basically a wrapper around `Phoenix.LiveComponent`, but it uses `AshPyro.Component` instead of `Phoenix.Component` to enable AshPyro's extended features.

  ```
  use AshPyro.LiveComponent
  ```

  > #### Note: {: .info}
  >
  > Please see the `Phoenix.LiveComponent` docs, as they will not be duplicated here.
  '''

  @doc false
  defmacro __using__(opts \\ []) do
    quote do
      @behaviour Phoenix.LiveComponent

      use AshPyro.Component, unquote(opts)

      import Phoenix.LiveView

      @before_compile Phoenix.LiveView.Renderer

      @doc false
      def __live__, do: %{kind: :component, module: __MODULE__, layout: false}
    end
  end
end
