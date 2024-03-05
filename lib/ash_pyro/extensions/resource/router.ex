defmodule AshPyro.Extensions.Resource.Router do
  @moduledoc """
  Tooling to generate routes for AshPyro's LiveView page DSL.
  """
  require Logger

  @doc """
  Generates live routes for a given LiveView, resource and page.

  ```elixir
  defmodule ExampleWeb.Router do
    use ExampleWeb, :router
    import AshPyro.Extensions.Resource.Router

    # ...

    scope "/", ExampleWeb do
      pipe_through :browser

      live_routes_for CompanyLive, Example.Company, :companies
      end
    end
  end
  ```
  """
  defmacro live_routes_for(live_view, resource, page_name) do
    live_view = Macro.expand(live_view, __CALLER__)
    resource = Macro.expand(resource, __CALLER__)
    pyro_page = AshPyro.Extensions.Resource.Info.page_for(resource, page_name)

    for %{path: path, live_action: live_action} <-
          Enum.sort(pyro_page.live_actions, &sort_routes/2) do
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

  defp sort_routes(%{path: left}, %{path: right}) do
    compare_paths(left, right)
  end

  defp compare_paths(left, right) do
    if left == right do
      Logger.warning("duplicate paths: #{inspect(left)}")
    end

    case {left, right} do
      # dynamic segments can be compared
      {[":" <> left_segment | left_rest], [":" <> right_segment | right_rest]} ->
        compare_paths([left_segment | left_rest], [right_segment | right_rest])

      # shorter paths should go last
      {[], _} ->
        false

      {_, []} ->
        true

      # dynamic segments must come after statuc segments
      {[":" <> _ | _], _} ->
        false

      {_, [":" <> _ | _]} ->
        true

      # identical segments must be compared on sub-path
      {[left_segment | left], [right_segment | right]} when left_segment == right_segment ->
        compare_paths(left, right)

      {[left_segment | _], [right_segment | _]} ->
        left_segment >= right_segment
    end
  end
end
