defmodule PyroManiac do
  @moduledoc """
  A declarative configuration of user interfaces for Ash resources.

  [DSL documentation](dsl-pyromaniac.html)
  """
  use Spark.Dsl,
    opt_schema: [
      resource: [
        type: {:spark, Ash.Resource},
        doc: "The Ash resource",
        required: true
      ]
    ],
    default_extensions: [extensions: [PyroManiac.Dsl]]

  alias Ash.Resource.Info

  @type t :: module

  @impl Spark.Dsl
  def init(opts) do
    resource = opts[:resource]

    if Info.resource?(resource) do
      {:ok, opts}
    else
      {:error, "#{resource} is not a valid Ash resource."}
    end
  end

  @impl Spark.Dsl
  def handle_opts(opts) do
    quote bind_quoted: [resource: opts[:resource]] do
      @persist {:resource, resource}
    end
  end
end
