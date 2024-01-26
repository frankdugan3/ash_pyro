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
  @spec form_for(Ash.Resource.t(), atom()) :: AshPyro.Extensions.Resource.Form.Action | nil
  def form_for(resource, action_name) do
    resource
    |> Spark.Dsl.Extension.get_entities([:pyro, :form])
    |> Enum.find(fn action ->
      action.name == action_name
    end)
  end

  def form_field(resource, action, field) do
    case form_for(resource, action) do
      nil -> nil
      %{fields: fields} -> Enum.find(fields, &(&1.name == field))
    end
  end

  @doc """
  Returns the page defined in the `AshPyro.Extensions.Resource` extension for the given page name.

  ## Examples

      iex> page_for(AshPyro.Extensions.Resource.InfoTest.User, :companies) |> Map.get(:name)
      :companies
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
  Returns the data table defined in the `AshPyro.Extensions.Resource` extension for the given action.

  ## Examples

      iex> data_table_for(AshPyro.Extensions.Resource.InfoTest.User, :list) |> Map.get(:name)
      :list
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
  Get a resource via a path from starting resource.
  """
  @spec resource_by_path(Ash.Resource.t(), [atom() | binary()]) :: Ash.Resource.t()
  def resource_by_path(resource, []), do: resource

  def resource_by_path(resource, [relationship | rest]) do
    case Ash.Resource.Info.field(resource, relationship) do
      %Ash.Resource.Aggregate{} ->
        resource

      %Ash.Resource.Calculation{} ->
        resource

      %Ash.Resource.Attribute{} ->
        resource

      %Ash.Resource.Relationships.BelongsTo{destination: destination} ->
        resource_by_path(destination, rest)

      %Ash.Resource.Relationships.HasOne{destination: destination} ->
        resource_by_path(destination, rest)

      %Ash.Resource.Relationships.HasMany{destination: destination} ->
        resource_by_path(destination, rest)

      %Ash.Resource.Relationships.ManyToMany{destination: destination} ->
        resource_by_path(destination, rest)
    end
  end
end
