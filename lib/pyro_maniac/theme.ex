defmodule PyroManiac.Theme do
  @moduledoc """
  Define a theme for PyroManiac UI components.
  """

  use Spark.Dsl, default_extensions: [extensions: [PyroManiac.Theme.Dsl]]

  @type t :: module
end
