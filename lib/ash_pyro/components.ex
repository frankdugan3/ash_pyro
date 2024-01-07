defmodule AshPyro.Components do
  @moduledoc """
  The easiest way to use Pyro/AshPyro components is to import them into `my_app_web.ex` helpers to make the available in all views and components:

   ```elixir
   defp html_helpers do
     quote do
       # Import all Pyro/AshPyro components
       use AshPyro.Components
       # ...
   ```

  Comprehensive installation instructions can be found in [Get Started](get-started.md).

  AshPyro provides components that support deep customization through `AshPyro.Overrides`, and also tooling to create your own via `AshPyro.Component`.

  > #### Note: {: .warning}
  >
  > Pyro's component names conflict with the generated `CoreComponents`. You will need to remove `import MyAppWeb.CoreComponents`.
  """

  defmacro __using__(_) do
    quote do
      use Pyro.Components

      import AshPyro.Components.DataTable
      import AshPyro.Components.Form

      alias AshPyro.Components.Page, as: AshPage
    end
  end
end
