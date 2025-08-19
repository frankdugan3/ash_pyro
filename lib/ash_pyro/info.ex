defmodule AshPyro.Info do
  @moduledoc """
  Helpers to introspect the `AshPyro.Extensions.Resource` Ash extension. Intended for use in components that automatically build UI from resource configuration.
  """

  alias Ash.Resource.Aggregate
  alias Ash.Resource.Attribute
  alias Ash.Resource.Calculation
  alias Ash.Resource.Info
  alias Ash.Resource.Relationships.BelongsTo
  alias Ash.Resource.Relationships.HasMany
  alias Ash.Resource.Relationships.HasOne
  alias Ash.Resource.Relationships.ManyToMany
  alias AshPyro.Extensions.Dsl.DataTable
  alias AshPyro.Extensions.Dsl.Form.Action
  alias AshPyro.Extensions.Dsl.LiveView.Page
  alias Spark.Dsl.Extension

  @doc """
  Returns the page defined in the `AshPyro.Extensions.Resource` extension for the given page name.

  ## Examples

      iex> page_for(AshPyro.InfoTest.User, :companies) |> Map.get(:name)
      :companies
  """
  @spec page_for(Ash.Resource.t(), atom()) :: Page.t() | nil
  def page_for(resource, page_name) do
    resource
    |> Extension.get_entities([:pyro, :live_view])
    |> Enum.find(fn page ->
      page.name == page_name
    end)
  end

  @doc """
  Returns the form fields defined in the `AshPyro.Extensions.Resource` extension for the given action.

  ## Examples

      iex> form_for(AshPyro.InfoTest.User, :create) |> Map.get(:fields) |> Enum.map(& &1.name)
      [:primary, :authorization, :friendships, :notes]
  """
  @spec form_for(Ash.Resource.t(), atom()) :: Action.t() | nil
  def form_for(resource, action_name) do
    resource
    |> Extension.get_entities([:pyro, :form])
    |> Enum.find(fn action ->
      action.name == action_name
    end)
  end

  def form_field(resource, action, field) do
    case form_for(resource, action) do
      %{fields: fields} when is_list(fields) -> Enum.find(fields, &(&1.name == field))
      _ -> nil
    end
  end

  @doc """
  Returns the data table defined in the `AshPyro.Extensions.Resource` extension for the given action.

  ## Examples

      iex> data_table_for(AshPyro.InfoTest.User, :list) |> Map.get(:name)
      :list
  """
  @spec data_table_for(Ash.Resource.t(), atom()) ::
          [
            DataTable
          ]
          | nil
  def data_table_for(resource, action_name) do
    resource
    |> Extension.get_entities([:pyro, :data_table])
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
    case Info.field(resource, relationship) do
      %Aggregate{} ->
        resource

      %Calculation{} ->
        resource

      %Attribute{} ->
        resource

      %BelongsTo{destination: destination} ->
        resource_by_path(destination, rest)

      %HasOne{destination: destination} ->
        resource_by_path(destination, rest)

      %HasMany{destination: destination} ->
        resource_by_path(destination, rest)

      %ManyToMany{destination: destination} ->
        resource_by_path(destination, rest)
    end
  end
end
