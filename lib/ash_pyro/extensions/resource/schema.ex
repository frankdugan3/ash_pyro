defmodule AshPyro.Extensions.Resource.Schema do
  @moduledoc """
  Shared types for resource extension schemas.
  """

  @type css_class :: any() | (map() -> any())
  @type sort ::
          String.t()
          | list({atom, Ash.Sort.sort_order()})
          | list(atom())
          | list(String.t())
          | nil

  @doc "schema type for CSS classes accepted by an Ash component"
  def css_class_schema_type do
    {:or, [:any, {:fun, 1}]}
  end

  @doc "build an inheritable type"
  def inheritable_schema_type(type \\ :string) do
    {:or, [type, {:one_of, [:inherit]}]}
  end

  @doc "acceptable formats for sorting options"
  def sort_schema_type do
    {:or,
     [
       :string,
       {:list,
        {:tuple,
         [
           :atom,
           {:in, [:asc, :desc, :asc_nils_first, :asc_nils_last, :desc_nils_first, :desc_nils_last]}
         ]}},
       {:list, :atom},
       {:list, :string},
       nil
     ]}
  end

  defmacro __using__(_env) do
    quote do
      import unquote(__MODULE__)

      alias unquote(__MODULE__)

      defdelegate fetch(term, key), to: Map
      defdelegate get(term, key, default), to: Map
      defdelegate get_and_update(term, key, fun), to: Map
    end
  end
end
