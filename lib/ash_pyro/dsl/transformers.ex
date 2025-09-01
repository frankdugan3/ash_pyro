defmodule AshPyro.Dsl.Transformers do
  @moduledoc false
  alias Ash.Resource.Info, as: ResourceInfo
  alias Ash.Resource.Relationships.{BelongsTo, HasMany, HasOne, ManyToMany}
  alias Ash.Resource.{Aggregate, Attribute, Calculation}
  alias Spark.Dsl.Transformer

  @doc """
  Get the Ash resource actions for an AshPyro DSL.
  """
  def get_resource_actions(dsl) do
    dsl
    |> Transformer.get_persisted(:resource)
    |> ResourceInfo.actions()
  end

  @doc """
  Get the type of a Ash resource field for an AshPyro DSL. Used to determine how to render it in the UI.
  """
  def resource_field_type(resource, field_name) do
    resource
    |> ResourceInfo.field(field_name)
    |> case do
      %Attribute{} -> :attribute
      %Aggregate{} -> :aggregate
      %Calculation{} -> :calculation
      %HasOne{} -> :has_one
      %BelongsTo{} -> :belongs_to
      %HasMany{} -> :has_many
      %ManyToMany{} -> :many_to_many
    end
  end

  @doc """
  Inherit a value from another enitity by name.
  """
  def inherit_pyro_config(dsl, kind, entity_name, key, default \\ nil)

  def inherit_pyro_config(dsl, path, entity_name, key, default) when is_list(path) do
    dsl
    |> Transformer.get_entities(path)
    |> Enum.find(&(&1.name == entity_name))
    |> get_nested(List.wrap(key), default)
  end

  def inherit_pyro_config(dsl, kind, entity_name, key, default) when kind in [:form] do
    inherit_pyro_config(dsl, [:form], entity_name, key, default)
  end

  def inherit_pyro_config(dsl, kind, entity_name, key, default) when kind in [:data_table] do
    inherit_pyro_config(dsl, [:data_table], entity_name, key, default)
  end

  def inherit_pyro_config(dsl, kind, entity_name, key, default)
      when kind in [:card, :card_grid] do
    inherit_pyro_config(dsl, [:card_grid], entity_name, key, default)
  end

  @doc """
  Safely get nested values from maps or keyword lists that may be `nil` or an otherwise non-map value at any point. Great for accessing nested assigns in a template.

  ## Examples

      iex> get_nested(nil, [:one, :two, :three])
      nil

      iex> get_nested(%{one: nil}, [:one, :two, :three])
      nil

      iex> get_nested(%{one: %{two: %{three: 3}}}, [:one, :two, :three])
      3

      iex> get_nested(%{one: %{two: [three: 3]}}, [:one, :two, :three])
      3

      iex> get_nested([one: :nope], [:one, :two, :three])
      nil

      iex> get_nested([one: :nope], [:one, :two, :three], :default)
      :default
  """
  def get_nested(value, keys, default \\ nil)
  def get_nested(value, [], _), do: value
  def get_nested(%{} = map, [key], default), do: Map.get(map, key, default)

  def get_nested(%{} = map, [key | keys], default),
    do: get_nested(Map.get(map, key), keys, default)

  def get_nested([_ | _] = keyword, [key], default), do: Keyword.get(keyword, key, default)

  def get_nested([_ | _] = keyword, [key | keys], default),
    do: get_nested(Keyword.get(keyword, key), keys, default)

  def get_nested(_, _, default), do: default

  @doc """
  Extract a default humanized label from an entity name.
  """
  def default_label(%{name: name}), do: default_label(name)
  def default_label(name) when is_atom(name), do: default_label(Atom.to_string(name))

  def default_label(name) when is_binary(name),
    do: name |> String.split("_") |> Enum.map_join(" ", &String.capitalize/1)

  @doc """
  Preserve path context when merging nested entities.
  """
  def maybe_append_path(root, []), do: root
  def maybe_append_path(root, path) when not is_nil(path), do: root ++ List.wrap(path)

  defmacro __using__(_env) do
    quote do
      use Spark.Dsl.Transformer

      import unquote(__MODULE__)
    end
  end
end
