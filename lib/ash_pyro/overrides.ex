defmodule AshPyro.Overrides do
  @moduledoc """
  The overrides system provides out-of-the-box presets while also enabling deep customization of AshPyro components.

  The `Pyro.Overrides.Default` preset is a great example to dig in and see how the override system works. A `AshPyro.Component` flags attrs with `overridable`, then leverages [`assign_overridables/1`](`Pyro.Component.assign_overridables/1`) to reference overrides set in these presets/custom override modules and load them as defaults.

  Pyro defaults to the following overrides:

  ```
  [Pyro.Overrides.Default]
  ```

  But you probably want to customize at least a few overrides. To do so, configure your app with:

  ```
  config :pyro, :overrides,
    [MyApp.CustomOverrides, AshPyro.Overrides.Default, Pyro.Overrides.Default]
  ```

  Then, define your overrides in your custom module:

  ```
  defmodule MyApp.CustomOverrides do
    @moduledoc false
    use AshPyro.Overrides

    override Core, :back do
      set :class, "text-lg font-black"
      set :icon_kind, :outline
      set :icon_name, :arrow_left
    end
  end
  ```

  The overrides will be merged left-to-right, returning the value in the *first* module that sets a given key. So in the above example, the `<Core.back>` component will have an `icon_name` default of `:arrow_left`, since the `MyApp.CustomOverrides` was the first module in the list to provide that key. But the `icon_class` was unspecified in the custom module, so it will return the value from `Pyro.Overrides.Default` since it is provided there:

  - You only need to define what you want to override from the other defaults
  - You can use any number of `:overrides` modules, though it is probably best to only use only 1-3 to keep things simple/efficient
  - If no modules define the value, it will simply be `nil`
  - If [`assign_overridables/1`](`Pyro.Component.assign_overridables/1`) is called on the component with the `required: true` attr option, an error will be raised if no configured overrides define a default
  """

  @doc false
  @spec __using__(any) :: Macro.t()
  defmacro __using__(_env) do
    quote do
      use Pyro.Overrides

      alias AshPyro.Components.DataTable, as: AshDataTable
      alias AshPyro.Components.Form, as: AshForm
      alias AshPyro.Components.Page, as: AshPage
    end
  end
end
