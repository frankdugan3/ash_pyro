defmodule AshPyro.Overrides.Default do
  @moduledoc """
  This is the default style configuration for AshPyro components. It complements `Pyro.Overrides.Default` by adding orverrides to all AshPyro components.

  It can be helpful to view the source of this override configuration to get an idea of how to write your own style overrides.
  """

  ##############################################################################
  ####    S T Y L E    S E T T I N G S
  ##############################################################################

  use AshPyro.Overrides

  ##############################################################################
  ####    A S H    C O M P O N E N T S
  ##############################################################################

  override AshDataTable, :ash_data_table do
    set :class, &__MODULE__.ash_data_table_class/1
  end

  def ash_data_table_class(passed_assigns) do
    get_nested(passed_assigns, [:pyro_data_table, :class])
  end

  override AshForm, :ash_form do
    set :class, &__MODULE__.ash_form_class/1
    set :actions_class, "pyro-ash_form__actions"
    set :autocomplete, "off"
  end

  def ash_form_class(passed_assigns) do
    ["pyro-ash_form", get_nested(passed_assigns, [:pyro_form, :class])]
  end

  override AshForm, :render_field do
    set :field_group_class, &__MODULE__.ash_form_field_group_class/1
    set :field_group_label_class, "pyro-ash_form__render_field__group_label"
  end

  def ash_form_field_group_class(passed_assigns) do
    ["pyro-ash_form__render_field__group", get_nested(passed_assigns, [:field, :class])]
  end
end
