defmodule PyroManiacTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Spark.Error.DslError

  doctest PyroManiac, import: true

  defmodule Author do
    use Ash.Resource, domain: PyroManiacTest.Domain

    attributes do
      uuid_primary_key :id
      attribute :name, :ci_string, public?: true
      attribute :email, :ci_string
    end

    actions do
      defaults [:read, :destroy, create: :*, update: :*]
    end
  end

  defmodule Post do
    use Ash.Resource, domain: PyroManiacTest.Domain

    attributes do
      uuid_primary_key :id
      attribute :title, :ci_string, public?: true, description: "The title for this post."
      attribute :content, :ci_string, public?: true
    end

    relationships do
      belongs_to :author, PyroManiacTest.Author, public?: true, allow_nil?: false
    end

    actions do
      defaults [:read, create: :*]

      update :change_author do
        accept [:title, :content]
        argument :author, :map, allow_nil?: false
        change manage_relationship(:author, type: :direct_control)
      end
    end
  end

  defmodule Domain do
    use Ash.Domain

    resources do
      resource Post
      resource Author
    end
  end

  defmodule Blog.Page do
    use PyroManiac, resource: Post

    form do
      exclude [:change_author]

      action :create do
        field :title, autofocus: true
        field :content
        field :author_id, label: "Author"
      end
    end

    data_table do
      description :inherit

      action_type :read do
        default_sort "title"
        exclude [:id, :author_id, :author]
        column :title, description: :inherit
        column :content
      end
    end
  end

  test "works" do
    assert Post = Blog.Page.persisted(:resource, nil)

    assert ~w[Title Content Author] =
             Blog.Page
             |> PyroManiac.Info.form_for(:create)
             |> Map.get(:fields)
             |> Enum.map(& &1.label)
  end

  describe "form verifiers" do
    test "detect duplicate actions" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.DuplicateActions]
                   form -> action:
                     :create is defined 2 times\
                   """,
                   fn ->
                     defmodule Blog.Form.DuplicateActions do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:change_author]

                         action :create do
                           field :title, autofocus: true
                           field :content
                           field :author_id
                         end

                         action :create do
                           field :title, autofocus: true
                           field :content
                           field :author_id
                         end
                       end
                     end
                   end
    end

    test "detect missing accept" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.MissingAccept]
                   form -> action -> create:
                     accepted attribute :content is not a form field\
                   """,
                   fn ->
                     defmodule Blog.Form.MissingAccept do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:change_author]

                         action :create do
                           field :title, autofocus: true
                           field :author_id
                         end
                       end
                     end
                   end
    end

    test "detect missing argument" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.MissingArgument]
                   form -> action -> change_author:
                     argument :author is not a form field\
                   """,
                   fn ->
                     defmodule Blog.Form.MissingArgument do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:create]

                         action :change_author do
                           field :title, autofocus: true
                           field :content
                         end
                       end
                     end
                   end
    end

    test "detect invalid field" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.InvalidField]
                   form -> action -> create:
                     field :not_real is not an accepted attribute or argument for this action\
                   """,
                   fn ->
                     defmodule Blog.Form.InvalidField do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:change_author]

                         action :create do
                           field :title, autofocus: true
                           field :content
                           field :author_id
                           field :not_real
                         end
                       end
                     end
                   end
    end

    test "validate autofocus" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.ZeroAutofocus]
                   form -> action -> create:
                     exactly one field must have autofocus\
                   """,
                   fn ->
                     defmodule Blog.Form.ZeroAutofocus do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:change_author]

                         action :create do
                           field :title
                           field :content
                           field :author_id
                         end
                       end
                     end
                   end

      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.TwoAutofocus]
                   form -> action -> create:
                     exactly one field must have autofocus\
                   """,
                   fn ->
                     defmodule Blog.Form.TwoAutofocus do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:change_author]

                         action :create do
                           field :title, autofocus: true
                           field :content, autofocus: true
                           field :author_id
                         end
                       end
                     end
                   end
    end

    test "detect duplicate field label" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.DuplicateFieldLabel]
                   form -> action -> create:
                     2 fields use the label "Title"\
                   """,
                   fn ->
                     defmodule Blog.Form.DuplicateFieldLabel do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:change_author]

                         action :create do
                           field :title, autofocus: true
                           field :content, label: "Title"
                           field :author_id
                         end
                       end
                     end
                   end
    end

    test "detect duplicate field" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.Form.DuplicateField]
                   form -> action -> create:
                     2 fields define :content\
                   """,
                   fn ->
                     defmodule Blog.Form.DuplicateField do
                       use PyroManiac, resource: Post

                       form do
                         exclude [:change_author]

                         action :create do
                           field :title, autofocus: true
                           field :content
                           field :content, label: "Content 2"
                           field :author_id
                         end
                       end
                     end
                   end
    end
  end

  describe "data_table verifiers" do
    test "detect duplicate actions" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.DuplicateActions]
                   data_table -> action:
                     :read is defined 2 times\
                   """,
                   fn ->
                     defmodule Blog.DataTable.DuplicateActions do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                         end

                         action :read do
                           default_sort "title"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                         end
                       end
                     end
                   end
    end

    test "detect duplicate columns" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.DuplicateColumns]
                   data_table -> action -> read:
                     2 columns define :title\
                   """,
                   fn ->
                     defmodule Blog.DataTable.DuplicateColumns do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :title, label: "Title 2"
                           column :content
                         end
                       end
                     end
                   end
    end

    test "detect duplicate column labels" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.DuplicateColumnLabels]
                   data_table -> action -> read:
                     2 columns use the label "Title"\
                   """,
                   fn ->
                     defmodule Blog.DataTable.DuplicateColumnLabels do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content, label: "Title"
                         end
                       end
                     end
                   end
    end

    test "detect missing public columns" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.MissingPublicColumns]
                   data_table -> action -> read:
                     public attribute :content is not a defined or excluded column\
                   """,
                   fn ->
                     defmodule Blog.DataTable.MissingPublicColumns do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           exclude [:id, :author_id, :author]
                           column :title
                         end
                       end
                     end
                   end
    end

    test "detect invalid default_sort" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.UndefinedColumnInDefaultSort]
                   data_table -> action -> read -> default_sort:
                     key [:author_id] is an undefined or excluded column\
                   """,
                   fn ->
                     defmodule Blog.DataTable.UndefinedColumnInDefaultSort do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "author_id"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                         end
                       end
                     end
                   end

      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.InvalidDefaultSort]
                   data_table -> action -> read -> default_sort:
                     "---title" is an invalid Ash sort.

                   Input Invalid

                   * No such field -title for resource PyroManiacTest.Post\
                   """,
                   fn ->
                     defmodule Blog.DataTable.InvalidDefaultSort do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "---title"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                         end
                       end
                     end
                   end

      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.NoSort]
                   data_table -> action -> read -> default_sort:
                     "": must sort on at least one column\
                   """,
                   fn ->
                     defmodule Blog.DataTable.NoSort do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort ""
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                         end
                       end
                     end
                   end
    end

    test "detect invalid default_display" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.NoDefaultDisplay]
                   data_table -> action -> read -> default_display:
                     must display at least one column by default\
                   """,
                   fn ->
                     defmodule Blog.DataTable.NoDefaultDisplay do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           default_display []
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                         end
                       end
                     end
                   end

      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.UndefinedColumnInDefaultDisplay]
                   data_table -> action -> read -> default_display:
                     :not_real is an undefined or excluded column\
                   """,
                   fn ->
                     defmodule Blog.DataTable.UndefinedColumnInDefaultDisplay do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           default_display [:not_real]
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                         end
                       end
                     end
                   end
    end

    test "detect invalid columns" do
      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.ColumnSourceNotExist]
                   data_table -> action -> read -> columns:
                     column :author_ssn source [:author] -> :ssn does not exist on Elixir.PyroManiacTest.Author\
                   """,
                   fn ->
                     defmodule Blog.DataTable.ColumnSourceNotExist do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                           column :author_ssn, source: [:author, :ssn]
                         end
                       end
                     end
                   end

      assert_raise DslError,
                   """
                   [PyroManiacTest.Blog.DataTable.ColumnSourcePrivate]
                   data_table -> action -> read -> columns:
                     column :author_email source [:author] -> :email is not public on Elixir.PyroManiacTest.Author\
                   """,
                   fn ->
                     defmodule Blog.DataTable.ColumnSourcePrivate do
                       use PyroManiac, resource: Post

                       data_table do
                         action :read do
                           default_sort "title"
                           exclude [:id, :author_id, :author]
                           column :title
                           column :content
                           column :author_email, source: [:author, :email]
                         end
                       end
                     end
                   end
    end
  end
end
