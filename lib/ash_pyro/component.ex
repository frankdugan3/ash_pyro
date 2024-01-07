defmodule AshPyro.Component do
  @moduledoc ~S'''
  `AshPyro.Component` extents `Pyro.Component` with utilities for building components that automatically render Ash resources.

  This is basically the same thing as `Phoenix.Component`, but Pyro extends the `attr/3` macro with:

  * `:css_classes` type
  * `:overridable` flag
  * `:values` supports an atom value (override key)

  Pyro also provides `assign_overridables/1`, which automatically assigns all flagged `overridable` attrs with defaults from `Pyro.Overrides`

  ## Example

  ```elixir
  defmodule MyApp.Components.ExternalLink do
    @moduledoc """
    An external link component.
    """
    use AshPyro.Component

    attr :overrides, :list, default: nil, doc: @overrides_attr_doc
    attr :class, :css_classes, overridable: true, required: true
    attr :href, :string, required: true
    attr :rest, :global, include: ~w[download hreflang referrerpolicy rel target type]
    slot :inner_block, required: true

    def external_link(assigns) do
      assigns = assign_overridables(assigns)
      ~H"""
      <a class={@class} href={@href}} {@rest}>
        <%= render_slot(@inner_block) %>
      </a>
      """
    end
  end
  ```

  > #### Note: {: .info}
  >
  > Only additional features will be documented here. Please see the `Pyro.Component` and `Phoenix.Component` docs for the rest, as they will not be duplicated here.
  '''
  @doc """
  Render classes for an AshPyro component.
  """
  def ash_class(fun, assigns) when is_function(fun, 1), do: fun.(assigns)

  def ash_class(class, _assigns), do: class

  defmacro __using__(_env) do
    quote do
      use Pyro.Component

      import unquote(__MODULE__)
    end
  end
end
