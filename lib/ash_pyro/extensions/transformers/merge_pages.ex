defmodule AshPyro.Extensions.Transformers.MergePages do
  @moduledoc false

  use AshPyro.Extensions.Transformers

  alias Ash.Resource.Dsl
  alias AshPyro.Extensions.Dsl.LiveView.Page
  alias AshPyro.Extensions.Transformers.MergeDataTableActions
  alias AshPyro.Extensions.Transformers.MergeFormActions

  require Logger

  @dependant_transformers Dsl.transformers() ++
                            [
                              MergeFormActions,
                              MergeDataTableActions
                              # AshPyro.Extensions.Transformers.MergeCardGridActions
                            ]

  @impl true
  def after?(module) when module in @dependant_transformers, do: true
  @impl true
  def after?(_), do: false

  @impl true
  def transform(dsl) do
    case Transformer.get_entities(dsl, [:pyro, :live_view]) do
      [] ->
        {:ok, dsl}

      page_entities ->
        dsl =
          Enum.reduce(page_entities, dsl, fn page_entity, dsl ->
            merge_page(page_entity, dsl)
          end)

        {:ok, dsl}
    end
  end

  defp merge_page(%Page{name: name, route_helper: nil} = page, dsl) do
    merge_page(%{page | route_helper: String.to_atom("#{name}_path")}, dsl)
  end

  defp merge_page(%Page{live_actions: live_actions, view_as: :list_and_modal} = page, dsl) do
    live_action_types =
      live_actions
      |> Enum.map(&expand_live_action_defaults(&1, dsl))
      |> partition_live_actions()

    live_actions =
      live_action_types.list
      |> Enum.reduce([], fn list, acc ->
        acc =
          Enum.reduce(live_action_types.show, acc, fn show, acc ->
            path =
              build_path([page.path, list.path, identity_to_path(show.identity), show.path])

            live_action = String.to_atom("#{list.live_action}_#{show.live_action}")

            [
              %{show | live_action: live_action, parent_action: list.live_action, path: path}
              | acc
            ]
          end)

        acc =
          Enum.reduce(live_action_types.update, acc, fn update, acc ->
            path =
              build_path([page.path, list.path, identity_to_path(update.identity), update.path])

            live_action = String.to_atom("#{list.live_action}_#{update.live_action}")

            [
              %{update | live_action: live_action, parent_action: list.live_action, path: path}
              | acc
            ]
          end)

        acc =
          Enum.reduce(live_action_types.create, acc, fn create, acc ->
            path = build_path([page.path, list.path, create.path])
            live_action = String.to_atom("#{list.live_action}_#{create.live_action}")

            [
              %{create | live_action: live_action, parent_action: list.live_action, path: path}
              | acc
            ]
          end)

        [
          %{list | parent_action: list.live_action, path: build_path([page.path, list.path])}
          | acc
        ]
      end)
      |> sort_live_actions()

    page = %{page | live_actions: live_actions}
    dsl = Transformer.replace_entity(dsl, [:pyro, :live_view], page)

    dsl
  end

  defp merge_page(%Page{live_actions: live_actions, view_as: :show_and_modal} = page, dsl) do
    live_action_types =
      live_actions
      |> Enum.map(&expand_live_action_defaults(&1, dsl))
      |> partition_live_actions()

    list_actions =
      Enum.map(live_action_types.list, fn list ->
        %{list | path: build_path([page.path, list.path])}
      end)

    live_actions =
      live_action_types.show
      |> Enum.reduce(list_actions, fn show, acc ->
        show_identity = identity_to_path(show.identity)

        acc =
          Enum.reduce(live_action_types.create, acc, fn action, acc ->
            path = build_path([page.path, show_identity, show.path, action.path])
            live_action = String.to_atom("#{show.live_action}_#{action.live_action}")

            [
              %{action | live_action: live_action, parent_action: show.live_action, path: path}
              | acc
            ]
          end)

        acc =
          Enum.reduce(live_action_types.update, acc, fn update, acc ->
            path =
              build_path([
                page.path,
                show_identity,
                show.path,
                identity_to_path(update.identity),
                update.path
              ])

            live_action = String.to_atom("#{show.live_action}_#{update.live_action}")

            [
              %{update | live_action: live_action, parent_action: show.live_action, path: path}
              | acc
            ]
          end)

        [
          %{
            show
            | parent_action: show.live_action,
              path: build_path([page.path, show_identity, show.path])
          }
          | acc
        ]
      end)
      |> sort_live_actions()

    page = %{page | live_actions: live_actions}
    dsl = Transformer.replace_entity(dsl, [:pyro, :live_view], page)

    dsl
  end

  defp merge_page(%Page{live_actions: live_actions, view_as: :individual} = page, dsl) do
    live_actions =
      live_actions
      |> Enum.map(&expand_live_action_defaults(&1, dsl))
      |> Enum.map(fn
        %Page.List{} = list ->
          %{list | path: build_path([page.path, list.path])}

        %Page.Show{} = show ->
          identity_path = identity_to_path(show.identity)
          %{show | path: build_path([page.path, identity_path, show.path])}

        %Page.Create{} = create ->
          %{create | path: build_path([page.path, create.path])}

        %Page.Update{} = update ->
          identity_path = identity_to_path(update.identity)
          %{update | path: build_path([page.path, identity_path, update.path])}
      end)
      |> sort_live_actions()

    page = %{page | live_actions: live_actions}
    dsl = Transformer.replace_entity(dsl, [:pyro, :live_view], page)

    dsl
  end

  defp build_path(path) do
    path
    |> List.wrap()
    |> List.flatten()
    |> Enum.flat_map(&String.split(&1, "/", trim: true))
    |> Enum.reject(&(&1 == "/"))
  end

  defp identity_to_path(identity) do
    identity
    |> List.wrap()
    |> Enum.map_join("/", &inspect/1)
  end

  defp expand_live_action_defaults(%Page.Update{load_action: nil} = live_action, dsl) do
    case_result =
      case dsl |> filter_actions(&(&1.type == :read && &1.primary? == true)) |> List.first() do
        nil ->
          raise DslError.exception(
                  path: [:pyro, :live_view, :page, :update],
                  message: """
                  no primary read action; you must specify the load_action or add a primary read action
                  """
                )

        %{name: name} ->
          %{live_action | load_action: name}
      end

    expand_live_action_defaults(case_result, dsl)
  end

  defp expand_live_action_defaults(%Page.List{action: action, pagination: nil} = live_action, dsl) do
    case_result =
      case dsl |> filter_actions(&(&1.type == :read && &1.name == action)) |> List.first() do
        %{pagination: %{offset?: true}} ->
          %{live_action | pagination: :offset}

        %{pagination: %{keyset?: true}} ->
          %{live_action | pagination: :keyset}

        _ ->
          %{live_action | pagination: :none}
      end

    expand_live_action_defaults(case_result, dsl)
  end

  defp expand_live_action_defaults(%Page.List{action: action, count?: nil} = live_action, dsl) do
    case_result =
      case dsl |> filter_actions(&(&1.type == :read && &1.name == action)) |> List.first() do
        %{pagination: %{countable: true, offset?: true}} ->
          %{live_action | count?: true}

        _ ->
          %{live_action | count?: false}
      end

    expand_live_action_defaults(case_result, dsl)
  end

  # TODO: Check
  defp expand_live_action_defaults(
         %Page.List{action: action, default_limit: nil} = live_action,
         dsl
       ) do
    case_result =
      case dsl |> filter_actions(&(&1.type == :read && &1.name == action)) |> List.first() do
        %{pagination: %{default_limit: limit}} when is_integer(limit) ->
          %{live_action | default_limit: limit}

        %{pagination: %{max_page_size: limit}} when is_integer(limit) ->
          %{live_action | default_limit: limit}

        _ ->
          %{live_action | default_limit: 250}
      end

    expand_live_action_defaults(case_result, dsl)
  end

  defp expand_live_action_defaults(%{label: :inherit} = live_action, dsl) do
    label =
      inherit_pyro_config(
        dsl,
        live_action.display_as,
        live_action.action,
        :label,
        default_label(live_action.live_action)
      )

    expand_live_action_defaults(%{live_action | label: label}, dsl)
  end

  defp expand_live_action_defaults(%{label: nil, live_action: name} = live_action, dsl) do
    expand_live_action_defaults(%{live_action | label: default_label(name)}, dsl)
  end

  defp expand_live_action_defaults(%{description: :inherit} = live_action, dsl) do
    description =
      inherit_pyro_config(dsl, live_action.display_as, live_action.action, :description)

    expand_live_action_defaults(%{live_action | description: description}, dsl)
  end

  defp expand_live_action_defaults(live_action, _dsl), do: live_action

  defp partition_live_actions(live_actions) do
    Enum.reduce(live_actions, %{create: [], list: [], show: [], update: []}, fn
      %Page.List{} = action, acc ->
        %{acc | list: [action | acc.list]}

      %Page.Show{} = action, acc ->
        %{acc | show: [action | acc.show]}

      %Page.Create{} = action, acc ->
        %{acc | create: [action | acc.create]}

      %Page.Update{} = action, acc ->
        %{acc | update: [action | acc.update]}
    end)
  end

  defp sort_live_actions(routes), do: Enum.sort(routes, &route_sorter/2)

  defp route_sorter(%{path: left}, %{path: right}) do
    compare_paths(left, right)
  end

  defp compare_paths(left, right) when left == right do
    Logger.warning("duplicate paths: #{inspect(left)}")
    true
  end

  # dynamic segment pairs are comparable
  defp compare_paths([":" <> left_segment | left], [":" <> right_segment | right]) do
    compare_paths([left_segment | left], [right_segment | right])
  end

  # shorter paths must go last
  defp compare_paths(_, []), do: true
  defp compare_paths([], _), do: false

  # dynamic segments must come after static segments
  defp compare_paths(_, [":" <> _ | _]), do: true
  defp compare_paths([":" <> _ | _], _), do: false

  # identical segments must be compared on sub-path
  defp compare_paths([left_segment | left], [right_segment | right])
       when left_segment == right_segment do
    compare_paths(left, right)
  end

  # normal comparison of segment
  defp compare_paths([left_segment | _], [right_segment | _]) do
    left_segment >= right_segment
  end
end
