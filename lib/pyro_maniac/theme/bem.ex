defmodule PyroManiac.Theme.BEM do
  @moduledoc """
  A PyroManiac theme implementation for BEM. You are expected to provide your own CSS implementation.
  """

  use PyroManiac.Theme

  theme do
    prefix "pyromaniac_"
    base_class :data_table, "table"
    base_class :form, "form"
  end
end
