defmodule Boodschapper.GroceriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Boodschapper.Groceries` context.
  """

  @doc """
  Generate a grocery.
  """
  def grocery_fixture(attrs \\ %{}) do
    {:ok, grocery} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Boodschapper.Groceries.create_grocery()

    grocery
  end
end
