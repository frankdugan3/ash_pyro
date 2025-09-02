defmodule PyroManiac.Theme do
  @moduledoc """
  Define a theme for PyroManiac UI components.
  """

  use Spark.Dsl, default_extensions: [extensions: [PyroManiac.Theme.Dsl]]

  alias PyroManiac.Theme.BaseClass

  @type t :: module

  @doc """
  List all the base class names required in a theme.

  ## Examples

      iex> base_class_names() |> Enum.find(& &1 == :form)
      :form
  """
  @base_class_names BaseClass.__entity__().schema[:name][:type] |> elem(1)
  def base_class_names, do: @base_class_names
end
