if Code.ensure_loaded?(Phoenix.LiveView) do
  defmodule PyroManiac.LiveView do
    @moduledoc """
    Phoenix LiveView components to automatically render PyroManiac DSL.
    """
    use Spark.Dsl,
      opt_schema: [
        endpoint: [
          type: {:behaviour, Phoenix.Endpoint},
          doc: "Your Phoenix endpoint",
          required: true
        ]
      ],
      default_extensions: [exensions: [PyroManiac.Theme.Dsl]]

    @type t :: module

    @impl Spark.Dsl
    def handle_opts(opts) do
      quote bind_quoted: [resource: opts[:endpoint]] do
        @persist {:endpoint, endpoint}
      end
    end
  end
end
