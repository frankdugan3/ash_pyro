defmodule AshPyro.Enum do
  @moduledoc false

  def humanize_enum(enum) when is_binary(enum) do
    String.replace(enum, "_", " ")
  end

  def humanize_enum(enum) when is_atom(enum) do
    humanize_enum(Atom.to_string(enum))
  end

  def humanize_enum(list) when is_list(list) do
    Enum.map_join(list, ", ", fn enum -> humanize_enum(enum) end)
  end

  defmacro __using__(opts) do
    quote do
      use Ash.Type.Enum, values: unquote(opts[:values])

      def form_options do
        Enum.map(__MODULE__.values(), fn enum ->
          {unquote(__MODULE__).humanize_enum(enum), Atom.to_string(enum)}
        end)
      end
    end
  end
end
