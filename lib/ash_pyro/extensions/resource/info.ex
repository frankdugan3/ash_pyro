defmodule AshPyro.Extensions.Resource.Info do
  @moduledoc """
  Helpers to introspect the `AshPyro.Extensions.Resource` Ash extension. Intended for use in components that automatically build UI from resource configuration.
  """

  @doc """
  Returns the form fields defined in the `AshPyro.Extensions.Resource` extension for the given action.

  ## Examples

      iex> form_for(AshPyro.Extensions.Resource.InfoTest.User, :create) |> Map.get(:fields) |> Enum.map(& &1.name)
      [:primary, :authorization, :friendships, :notes]
  """
  @spec form_for(Ash.Resource.t(), atom()) ::
          [
            AshPyro.Extensions.Resource.Form.Field.t()
            | AshPyro.Extensions.Resource.Form.FieldGroup.t()
          ]
          | nil
  def form_for(resource, action_name) do
    resource
    |> Spark.Dsl.Extension.get_entities([:pyro, :form])
    |> Enum.find(fn action ->
      action.name == action_name
    end)
  end

  @doc """
  Same as `&form_for\2`, but raises if not found.
  """
  @spec form_for!(Ash.Resource.t(), atom()) ::
          [
            AshPyro.Extensions.Resource.Form.Field.t()
            | AshPyro.Extensions.Resource.Form.FieldGroup.t()
          ]
  def form_for!(resource, action_name) do
    form_for(resource, action_name) || raise "unable to find form"
  end

  @doc """
  Returns the page defined in the `AshPyro.Extensions.Resource` extension for the given page name.

  ## Examples

      iex> page_for(AshPyro.Extensions.Resource.InfoTest.User, :list) |> Enum.map(& &1.name)
      :list
  """
  @spec page_for(Ash.Resource.t(), atom()) :: AshPyro.Extensions.Resource.LiveView.Page | nil
  def page_for(resource, page_name) do
    resource
    |> Spark.Dsl.Extension.get_entities([:pyro, :live_view])
    |> Enum.find(fn page ->
      page.name == page_name
    end)
  end

  @doc """
  Same as `&page_for\2`, but raises if not found.
  """
  @spec page_for!(Ash.Resource.t(), atom()) :: AshPyro.Extensions.Resource.LiveView.Page
  def page_for!(resource, page_name) do
    page_for(resource, page_name) || raise "unable to find page"
  end

  @doc """
  Returns the data table defined in the `AshPyro.Extensions.Resource` extension for the given action.

  ## Examples

      iex> data_table_for(AshPyro.Extensions.Resource.InfoTest.User, :list) |> Enum.map(& &1.name)
      [:list]
  """
  @spec data_table_for(Ash.Resource.t(), atom()) ::
          [
            AshPyro.Extensions.Resource.DataTable
          ]
          | nil
  def data_table_for(resource, action_name) do
    resource
    |> Spark.Dsl.Extension.get_entities([:pyro, :data_table])
    |> Enum.find(fn action ->
      action.name == action_name
    end)
  end

  @doc """
  Same as `&data_table_for\2`, but raises if not found.
  """
  @spec data_table_for!(Ash.Resource.t(), atom()) ::
          [
            AshPyro.Extensions.Resource.DataTable
          ]
  def data_table_for!(resource, action_name) do
    data_table_for(resource, action_name) || raise "unable to find data table"
  end
end
