defmodule PyroManiac.Theme.Dsl.Transformers.ApplyPrefix do
  @moduledoc """
  Apply prefix to all base classes.
  """
  use PyroManiac.Dsl.Transformers

  alias PyroManiac.Theme.BaseClass
  alias Spark.Dsl.Transformer

  @impl true
  def after?(_), do: false

  @impl true
  def transform(dsl) do
    prefix = Transformer.get_option(dsl, [:theme], :prefix, "")

    dsl =
      dsl
      |> Transformer.get_entities([:theme])
      |> Enum.reduce(dsl, fn
        %BaseClass{} = base_class, dsl ->
          Transformer.replace_entity(
            dsl,
            [:theme],
            Map.put(base_class, :prefixed, prefix <> base_class.value)
          )

        _, dsl ->
          dsl
      end)

    {:ok, dsl}
  end
end
