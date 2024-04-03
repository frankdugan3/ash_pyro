defmodule AshPyro.Extensions.Resource.Router do
  @moduledoc """
  Tooling to generate routes for AshPyro's LiveView page DSL.
  """

  @doc """
  Generates live routes for a given LiveView, resource and page.

  ```elixir
  defmodule ExampleWeb.Router do
    use ExampleWeb, :router
    import AshPyro.Extensions.Resource.Router

    # ...

    scope "/", ExampleWeb do
      pipe_through :browser

      live_routes_for CompanyLive, :companies
      end
    end
  end
  ```
  """
  defmacro live_routes_for(live_view, resource, page_name) do
    live_view = Macro.expand(live_view, __CALLER__)
    resource = Macro.expand(resource, __CALLER__)
    pyro_page = AshPyro.Extensions.Resource.Info.page_for(resource, page_name)

    for %{path: path, live_action: live_action} <- pyro_page.live_actions do
      path = Enum.join(["" | path], "/")

      quote do
        live(
          unquote(path),
          unquote(live_view),
          unquote(live_action),
          as: unquote(page_name)
        )
      end
    end
  end
end
