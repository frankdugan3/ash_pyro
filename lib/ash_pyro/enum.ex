defmodule AshPyro.Enum do
  @moduledoc """
  Some tooling for Enums that makes using them in application logic and forms easier and more robust.
  """
  @doc """
  Pyro recommends the opinionated enum naming convention of using proper capitalization and replacing spaces with `_`. With this simple convention, a humanized label can be easily derived while maintaining enum compatability with Elixir, Postgres, and GraphQL.

  ## Examples

      iex> humanize_enum(:Some_Thing)
      "Some Thing"

      iex> humanize_enum(:IT_Admin)
      "IT Admin"

      iex> humanize_enum(["Auditor", :Human_Resources])
      "Auditor, Human Resources"
  """
  def humanize_enum(enum) when is_binary(enum) do
    String.replace(enum, "_", " ")
  end

  def humanize_enum(enum) when is_atom(enum) do
    humanize_enum(Atom.to_string(enum))
  end

  def humanize_enum(list) when is_list(list) do
    Enum.map_join(list, ", ", fn enum -> humanize_enum(enum) end)
  end

  defmacro __using__(opts \\ []) do
    enum_module = __MODULE__

    {sigil_name, opts} =
      Keyword.pop(
        opts,
        :sigil_name,
        __CALLER__.module
        |> Module.split()
        |> List.last()
        |> String.upcase()
      )

    sigil_fn = String.to_atom("sigil_" <> sigil_name)

    [
      quote do
        use Ash.Type.Enum, unquote(opts)
      end,
      quote bind_quoted: [
              enum_module: enum_module,
              sigil_name: sigil_name,
              sigil_fn: sigil_fn
            ] do
        def form_options do
          Enum.map(unquote(__MODULE__).values(), fn enum ->
            {unquote(enum_module).humanize_enum(enum), Atom.to_string(enum)}
          end)
        end

        defmacro unquote(sigil_fn)({:<<>>, _meta, [string]}, modifiers) when is_binary(string) do
          unquote(enum_module).parse_sigil(
            string,
            modifiers,
            __CALLER__,
            unquote(__MODULE__),
            unquote(sigil_name)
          )
        end

        defmacro __using__(_opts) do
          sigil_fn = unquote(sigil_fn)

          quote do
            import unquote(__MODULE__), only: unquote(Keyword.new([{sigil_fn, 2}]))

            alias unquote(__MODULE__)
          end
        end
      end
    ]
  end

  @doc false
  # Intended for internal use only by the enum sigil macro.
  def parse_sigil(string, modifiers, caller, module, sigil_name) when is_binary(string) do
    string
    |> String.split()
    |> Enum.reduce([], fn value, acc ->
      case module.match(value) do
        {:ok, enum} ->
          deduplicate_enum(acc, enum, caller)

        _ ->
          stacktrace = Macro.Env.stacktrace(caller)

          reraise(
            ArgumentError,
            [message: "invalid enum in ~#{sigil_name}: \"#{value}\""],
            stacktrace
          )
      end
    end)
    |> cast_enum_type(modifiers, caller, sigil_name)
  end

  defp cast_enum_type(enums, [], caller, sigil_name),
    do: cast_enum_type(enums, [?a], caller, sigil_name)

  defp cast_enum_type(enums, modifiers, caller, sigil_name) do
    {type, list?} = parse_modifiers(modifiers, caller, sigil_name)
    transformed_enums = transform_enums(enums, type)
    format_result(transformed_enums, type, list?, caller, sigil_name)
  end

  defp parse_modifiers(modifiers, caller, sigil_name) do
    Enum.reduce(modifiers, {nil, false}, fn
      mod, {nil, list?} when mod in [?a, ?s, ?h, ?o] ->
        {mod, list?}

      mod, {old, _} when mod in [?a, ?s, ?h, ?o] ->
        raise_modifier_conflict(caller, sigil_name, old, mod)

      ?l, {old, _} ->
        {old, true}

      mod, _acc ->
        raise_unknown_modifier(caller, sigil_name, mod)
    end)
  end

  defp transform_enums(enums, type) do
    case type do
      ?a -> enums
      ?s -> Enum.map(enums, &Atom.to_string/1)
      ?h -> Enum.map(enums, &humanize_enum/1)
      ?o -> Enum.map(enums, &{humanize_enum(&1), &1})
      _ -> enums
    end
  end

  defp format_result(enums, type, list?, caller, _sigil_name) do
    cond do
      !list? && type == ?h -> Enum.join(enums, ", ")
      list? && type == ?h -> enums
      list? -> enums
      !list? && length(enums) == 1 -> hd(enums)
      true -> raise_multiple_enums_error(caller)
    end
  end

  defp raise_modifier_conflict(caller, sigil_name, old, mod) do
    stacktrace = Macro.Env.stacktrace(caller)

    reraise(
      ArgumentError,
      [
        message:
          "sigil ~#{sigil_name} can only take one type mod, you tried both #{old} and #{mod}"
      ],
      stacktrace
    )
  end

  defp raise_unknown_modifier(caller, sigil_name, mod) do
    stacktrace = Macro.Env.stacktrace(caller)

    reraise(
      ArgumentError,
      [message: "unknown modifier \"#{mod}\" passed to sigil ~#{sigil_name}"],
      stacktrace
    )
  end

  defp raise_multiple_enums_error(caller) do
    stacktrace = Macro.Env.stacktrace(caller)

    reraise(
      ArgumentError,
      [
        message:
          "you provided more than one enum, but did not specify you wanted a list with the \"l\" modifier"
      ],
      stacktrace
    )
  end

  defp deduplicate_enum(enums, enum, caller) do
    if Enum.find(enums, &(&1 == enum)) do
      stacktrace = Macro.Env.stacktrace(caller)

      reraise(
        ArgumentError,
        [message: "duplicated enum: #{inspect(enum)}"],
        stacktrace
      )
    else
      [enum | enums]
    end
  end
end
