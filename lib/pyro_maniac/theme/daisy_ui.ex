defmodule PyroManiac.Theme.DaisyUI do
  @moduledoc """
  A PyroManiac theme implementation for DaisyUI
  """

  use PyroManiac.Theme

  theme do
    base_class :data_table, "table"
    base_class :form, "fieldset"
  end
end
