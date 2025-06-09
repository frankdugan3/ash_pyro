defmodule AshPyro.Extensions.Resource.Transformers do
  @moduledoc """
  Tooling for Ash resource transformation.
  """

  alias Spark.Dsl.Transformer

  @doc """
  Get the type of a resources field. Used to determine how to render it in the UI.
  """
  def resource_field_type(dsl, field_name) do
    [:attributes, :aggregates, :calculations, :relationships]
    |> Enum.flat_map(&Transformer.get_entities(dsl, [&1]))
    |> Enum.find(&(&1.name == field_name))
    |> case do
      %Ash.Resource.Attribute{} -> :attribute
      %Ash.Resource.Aggregate{} -> :aggregate
      %Ash.Resource.Calculation{} -> :calculation
      %Ash.Resource.Relationships.HasOne{} -> :has_one
      %Ash.Resource.Relationships.BelongsTo{} -> :belongs_to
      %Ash.Resource.Relationships.HasMany{} -> :has_many
      %Ash.Resource.Relationships.ManyToMany{} -> :many_to_many
    end
  end

  @doc """
  Get a filtered list of actions from the resource DSL.
  """
  def filter_actions(dsl, filter) do
    dsl
    |> Transformer.get_entities([:actions])
    |> Enum.filter(filter)
  end

  @doc """
  Get a specific action from the resource DSL.
  """
  def get_action(dsl, action) do
    dsl |> Transformer.get_entities([:actions]) |> Enum.find(&(&1.name == action))
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
    inherit_pyro_config(dsl, [:pyro, :form], entity_name, key, default)
  end

  def inherit_pyro_config(dsl, kind, entity_name, key, default) when kind in [:data_table] do
    inherit_pyro_config(dsl, [:pyro, :data_table], entity_name, key, default)
  end

  def inherit_pyro_config(dsl, kind, entity_name, key, default)
      when kind in [:card, :card_grid] do
    inherit_pyro_config(dsl, [:pyro, :card_grid], entity_name, key, default)
  end

  @doc """
  Collect all accumulated errors and log raise them all at once.
  """
  def handle_errors(errors, label, dsl \\ nil) do
    case errors do
      [] ->
        if dsl do
          {:ok, dsl}
        else
          :ok
        end

      [error] ->
        {:error, error}

      errors ->
        list =
          errors
          |> Enum.reverse()
          |> Enum.map_join("\n", &("   - " <> &1.message))

        {:error,
         Spark.Error.DslError.exception(
           path: [:pyro, :data_table],
           message: """
           There are multiple errors with the #{label}:
           #{list}
           """
         )}
    end
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

  defmacro __using__(_env) do
    quote do
      use Spark.Dsl.Transformer

      import unquote(__MODULE__)

      alias Spark.Dsl.Transformer
      alias Spark.Error.DslError
    end
  end
end
