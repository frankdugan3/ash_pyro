defmodule AshPyro.Extensions.Resource.Transformers.MergePages do
  @moduledoc false

  use AshPyro.Extensions.Resource.Transformers

  alias AshPyro.Extensions.Resource.LiveView.Page

  require Logger

  @dependant_transformers Ash.Resource.Dsl.transformers() ++
                            [
                              AshPyro.Extensions.Resource.Transformers.MergeFormActions,
                              AshPyro.Extensions.Resource.Transformers.MergeDataTableActions
                              # AshPyro.Extensions.Resource.Transformers.MergeCardGridActions
                            ]

  @impl true
  def after?(module) when module in @dependant_transformers, do: true
  @impl true
  def after?(_), do: false

  @impl true
  def transform(dsl) do
    errors = []

    case Transformer.get_entities(dsl, [:pyro, :live_view]) do
      [] ->
        {:ok, dsl}

      page_entities ->
        {dsl, errors} = Enum.reduce(page_entities, {dsl, errors}, &merge_page/2)

        handle_errors(errors, "live view pages", dsl)
    end
  end

  defp merge_page(%Page{route_helper: nil, name: name} = page, acc) do
    merge_page(%{page | route_helper: String.to_atom("#{name}_path")}, acc)
  end

  defp merge_page(
         %Page{view_as: :list_and_modal, live_actions: live_actions} = page,
         {dsl, errors}
       ) do
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
              %{show | path: path, live_action: live_action, parent_action: list.live_action}
              | acc
            ]
          end)

        acc =
          Enum.reduce(live_action_types.update, acc, fn update, acc ->
            path =
              build_path([page.path, list.path, identity_to_path(update.identity), update.path])

            live_action = String.to_atom("#{list.live_action}_#{update.live_action}")

            [
              %{update | path: path, live_action: live_action, parent_action: list.live_action}
              | acc
            ]
          end)

        acc =
          Enum.reduce(live_action_types.create, acc, fn create, acc ->
            path = build_path([page.path, list.path, create.path])
            live_action = String.to_atom("#{list.live_action}_#{create.live_action}")

            [
              %{create | path: path, live_action: live_action, parent_action: list.live_action}
              | acc
            ]
          end)

        [
          %{list | path: build_path([page.path, list.path]), parent_action: list.live_action}
          | acc
        ]
      end)
      |> sort_live_actions()

    page = %{page | live_actions: live_actions}
    dsl = Transformer.replace_entity(dsl, [:pyro, :live_view], page)

    {dsl, errors}
  end

  defp merge_page(
         %Page{view_as: :show_and_modal, live_actions: live_actions} = page,
         {dsl, errors}
       ) do
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
              %{action | path: path, live_action: live_action, parent_action: show.live_action}
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
              %{update | path: path, live_action: live_action, parent_action: show.live_action}
              | acc
            ]
          end)

        [
          %{
            show
            | path: build_path([page.path, show_identity, show.path]),
              parent_action: show.live_action
          }
          | acc
        ]
      end)
      |> sort_live_actions()

    page = %{page | live_actions: live_actions}
    dsl = Transformer.replace_entity(dsl, [:pyro, :live_view], page)

    {dsl, errors}
  end

  defp merge_page(%Page{view_as: :individual, live_actions: live_actions} = page, {dsl, errors}) do
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

    {dsl, errors}
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

  defp expand_live_action_defaults(%Page.List{pagination: nil, action: action} = live_action, dsl) do
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

  defp expand_live_action_defaults(%Page.List{count?: nil, action: action} = live_action, dsl) do
    case_result =
      case dsl |> filter_actions(&(&1.type == :read && &1.name == action)) |> List.first() do
        %{pagination: %{offset?: true, countable: true}} ->
          %{live_action | count?: true}

        _ ->
          %{live_action | count?: false}
      end

    expand_live_action_defaults(case_result, dsl)
  end

  # TODO: Check
  defp expand_live_action_defaults(
         %Page.List{default_limit: nil, action: action} = live_action,
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

  defp expand_live_action_defaults(%{live_action: name, label: nil} = live_action, dsl) do
    expand_live_action_defaults(%{live_action | label: default_label(name)}, dsl)
  end

  defp expand_live_action_defaults(%{description: :inherit} = live_action, dsl) do
    description =
      inherit_pyro_config(dsl, live_action.display_as, live_action.action, :description)

    expand_live_action_defaults(%{live_action | description: description}, dsl)
  end

  defp expand_live_action_defaults(live_action, _dsl), do: live_action

  defp partition_live_actions(live_actions) do
    Enum.reduce(live_actions, %{list: [], show: [], create: [], update: []}, fn
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
