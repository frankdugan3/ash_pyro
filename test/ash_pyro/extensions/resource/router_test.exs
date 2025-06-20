defmodule AshPyro.Extensions.Resource.RouterTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias AshPyro.Extensions.Resource.Router

  require Ash.Query

  doctest AshPyro.Extensions.Resource.Router, import: true

  defmodule User do
    @moduledoc false
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshPyro.Extensions.Resource],
      notifiers: [Ash.Notifier.PubSub],
      domain: AshPyro.Extensions.Resource.RouterTest.Domain

    require Ash.Query

    pyro do
      data_table do
        live_view do
          page "/users", :users do
            show "/", :show, :read
            update "/edit", :edit, :read
            create "/new", :new, :read
            list "/", :index, :read
          end
        end

        action_type [:read] do
          exclude [:id, :name_email, :best_friend]
          column :name
          column :email
          column :role
          column :active
          column :notes
        end
      end

      form do
        action_type [:create, :update] do
          class "max-w-md justify-self-center"

          field_group :primary do
            label "Primary Info"
            class "md:grid-cols-2"

            field :name do
              description "Your full real name"
              autofocus true
            end

            field :email
          end

          field_group :authorization do
            label "Authorization"
            class "md:grid-cols-2"

            field :role do
              label "Role"
            end

            field :active do
              label "Active"
            end
          end

          field_group :friendships do
            label "Friendships"

            field :best_friend_id do
              label "Best Friend"
              type :autocomplete
              prompt "Search friends for your bestie"
              autocomplete_option_label_key :name_email
            end
          end

          field :notes do
            type :long_text
            input_class "min-h-[10rem]"
          end
        end
      end
    end

    # pub_sub do
    #   prefix "user"

    #   publish_all :create, "created"
    #   publish_all :update, ["updated", [:id, nil]]
    #   publish_all :destroy, ["destroyed", [:id, nil]]
    # end

    attributes do
      uuid_primary_key :id
      attribute :name, :string, allow_nil?: false, public?: true

      attribute :email, :string,
        sensitive?: true,
        allow_nil?: false,
        constraints: [
          max_length: 160
        ],
        public?: true

      attribute :active, :boolean, allow_nil?: false, default: true, public?: true

      attribute :role, :atom,
        allow_nil?: false,
        constraints: [one_of: ~w[reader author editor admin]a],
        default: :reader,
        public?: true

      attribute :notes, :string,
        description: "Note anything unusual about yourself",
        public?: true
    end

    relationships do
      belongs_to :best_friend, __MODULE__
    end

    calculations do
      calculate :name_email, :ci_string do
        calculation expr(name <> " (" <> email <> ")")
      end
    end

    actions do
      default_accept :*
      defaults [:read, :destroy]

      read :list do
        prepare build(sort: [:name])
      end

      read :autocomplete do
        argument :search, :ci_string

        prepare fn query, _ ->
          search_string = Ash.Query.get_argument(query, :search)

          query
          |> Ash.Query.filter(
            if ^search_string != "" do
              contains(name_email, ^search_string)
            else
              true
            end
          )
          |> Ash.Query.load(:name_email)
          |> Ash.Query.sort(:name_email)
          |> Ash.Query.limit(10)
        end
      end

      create :create do
        primary? true
        argument :best_friend_id, :uuid
        change manage_relationship(:best_friend_id, :best_friend, type: :append_and_remove)

        description "Just an ordinary create action."
      end

      update :update do
        primary? true
        require_atomic? false
        argument :best_friend_id, :uuid
        change manage_relationship(:best_friend_id, :best_friend, type: :append_and_remove)
      end
    end

    code_interface do
      define :autocomplete, action: :autocomplete, args: [:search]
      define :list, action: :list
      define :by_id, action: :read, get_by: [:id]
      define :create, action: :create
      define :destroy, action: :destroy
    end
  end

  defmodule Domain do
    @moduledoc false
    use Ash.Domain

    resources do
      resource User
    end
  end

  # Not a real LiveView, not needed.
  defmodule UserLive do
    @moduledoc false
  end

  # Dummy live route, just to validate the order of paths.
  defp live(path, _live_view, _live_action, _opts) do
    path
  end

  test "router sorts routes correctly" do
    assert Router.live_routes_for(UserLive, User, :users) ==
             [
               "/users/new",
               "/users/:id/edit",
               "/users/:id",
               "/users"
             ]
  end
end
