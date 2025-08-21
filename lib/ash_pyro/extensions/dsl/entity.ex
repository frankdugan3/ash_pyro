defmodule AshPyro.Extensions.Dsl.Entity do
  @moduledoc false

  @css_class_schema {:or, [:any, {:fun, 1}]}
  @pagination_schema {:one_of, [:keyset, :offset, :none]}
  @sort_schema {:or,
                [
                  :string,
                  {:list,
                   {:tuple,
                    [
                      :atom,
                      {:one_of,
                       [
                         :asc,
                         :desc,
                         :asc_nils_first,
                         :asc_nils_last,
                         :desc_nils_first,
                         :desc_nils_last
                       ]}
                    ]}},
                  {:list, :atom},
                  {:list, :string},
                  nil
                ]}

  defp inheritable_schema(type) do
    {:or, [type, {:one_of, [:inherit]}]}
  end

  defp field_to_spec({key, field}) do
    {key, type_to_spec(field[:type])}
  end

  defp type_to_spec(:string), do: quote(do: String.t())
  defp type_to_spec(:any), do: quote(do: term())
  defp type_to_spec(:boolean), do: quote(do: boolean())
  defp type_to_spec(:pos_integer), do: quote(do: pos_integer())
  defp type_to_spec(:atom), do: quote(do: atom())
  defp type_to_spec(nil), do: quote(do: nil)
  defp type_to_spec({:fun, arity}) when is_integer(arity), do: quote(do: fun())
  defp type_to_spec({:inheritable, type}), do: type_to_spec(inheritable_schema(type))
  defp type_to_spec(:pagination), do: type_to_spec(@pagination_schema)
  defp type_to_spec(:css_class), do: type_to_spec(@css_class_schema)
  defp type_to_spec(:sort), do: type_to_spec(@sort_schema)

  defp type_to_spec({:tuple, sub_types}),
    do: quote(do: {unquote_splicing(Enum.map(sub_types, &type_to_spec/1))})

  defp type_to_spec({list, sub_type}) when list in [:list, :wrap_list],
    do: quote(do: list(unquote(type_to_spec(sub_type))))

  defp type_to_spec({one_of, types}) when one_of in [:in, :one_of],
    do: Enum.reduce(types, &quote(do: unquote(&1) | unquote(&2)))

  defp type_to_spec({:or, sub_types}),
    do: Enum.reduce(sub_types, &quote(do: unquote(type_to_spec(&1)) | unquote(&2)))

  defp opts_for_entity(opts, caller) do
    opts
    |> Keyword.update(:schema, [], fn fields ->
      Enum.map(fields, fn {field, schema} ->
        {field,
         schema
         |> Keyword.update!(:type, fn
           :css_class -> @css_class_schema
           :pagination -> @pagination_schema
           :sort -> @sort_schema
           {:inheritable, type} -> inheritable_schema(type)
           type -> type
         end)}
      end)
    end)
    |> Keyword.update(:entities, [], fn fields ->
      Enum.map(fields, fn {field, entities} ->
        {field, Enum.map(entities, &quote(do: unquote(Macro.expand(&1, caller)).__entity__()))}
      end)
    end)
  end

  defp opts_to_typespec(opts, caller) do
    fields = Enum.map(opts[:schema], &field_to_spec/1)

    entities =
      for {field, entities} <- opts[:entities] || [] do
        spec =
          entities
          |> Enum.map(&quote do: unquote(Macro.expand(&1, caller)).t())
          |> Enum.reduce(&quote do: unquote(&1) | unquote(&2))

        quote do: {unquote(field), list(unquote(spec))}
      end

    fields ++ entities
  end

  defmacro __using__(opts) do
    opts = Keyword.put(opts, :target, __CALLER__.module)
    entity_opts = opts_for_entity(opts, __CALLER__)
    typespec = opts_to_typespec(opts, __CALLER__)
    struct_fields = Keyword.keys(opts[:schema]) ++ Keyword.keys(opts[:entities] || [])

    quote do
      @moduledoc @moduledoc <> Spark.Options.docs(unquote(entity_opts[:schema]))
      alias Spark.Dsl.Entity

      @type t :: %__MODULE__{unquote_splicing(typespec)}
      defstruct unquote(struct_fields)
      @entity struct!(Entity, unquote(entity_opts))
      @doc false
      defdelegate fetch(term, key), to: Map
      @doc false
      defdelegate get(term, key, default), to: Map
      @doc false
      defdelegate get_and_update(term, key, fun), to: Map
      @doc false
      def __entity__, do: @entity
    end
  end
end
