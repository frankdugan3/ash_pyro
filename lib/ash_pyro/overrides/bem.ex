defmodule AshPyro.Overrides.BEM do
  @moduledoc """
    This overrides file complements `Pyro.Overrides.BEM` by adding [BEM](https://getbem.com/) classes to all AshPyro components. It does not define any style.

    This is great if you want to fully customize your own styles; all you have to do is define the classes in your CSS file.

    ## Configuration

    As with any Pyro overrides, you need to include the correct override files in your `config.exs` file:

    ```elixir
    config :pyro, :overrides, [AshPyro.Overrides.BEM, Pyro.Overrides.BEM]
    ```
  """

  ##############################################################################
  ####    S T Y L E    S E T T I N G S
  ##############################################################################

  use AshPyro.Overrides

  @prefix Application.compile_env(:pyro, :bem_prefix, "")

  ##############################################################################
  ####    A S H    C O M P O N E N T S
  ##############################################################################

  @prefixed_smart_data_table @prefix <> "smart_data_table"
  override AshDataTable, :smart_data_table do
    set :class, &__MODULE__.smart_data_table_class/1
  end

  def smart_data_table_class(passed_assigns) do
    [@prefixed_smart_data_table, get_nested(passed_assigns, [:pyro_data_table, :class])]
  end

  @prefixed_smart_form @prefix <> "smart_form"
  override AshForm, :smart_form do
    set :class, &__MODULE__.smart_form_class/1
    set :actions_class, @prefixed_smart_form <> "__actions"
    set :autocomplete, "off"
  end

  def smart_form_class(passed_assigns) do
    [@prefixed_smart_form, get_nested(passed_assigns, [:pyro_form, :class])]
  end

  @prefixed_smart_form_render_field @prefix <> "smart_form_render_field"
  override AshForm, :render_field do
    set :field_group_class, &__MODULE__.smart_form_field_group_class/1
    set :field_group_label_class, @prefixed_smart_form_render_field("__group_label")
  end

  def smart_form_field_group_class(passed_assigns) do
    [
      @prefixed_smart_form_render_field <> "__group",
      get_nested(passed_assigns, [:field, :class])
    ]
  end
end
