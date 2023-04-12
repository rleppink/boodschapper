defmodule Boodschapper.GroceriesTest do
  use Boodschapper.DataCase

  alias Boodschapper.Groceries

  describe "groceries" do
    alias Boodschapper.Groceries.Grocery

    import Boodschapper.GroceriesFixtures

    @invalid_attrs %{name: nil}

    test "list_groceries/0 returns all groceries" do
      grocery = grocery_fixture()
      assert Groceries.list_groceries() == [grocery]
    end

    test "get_grocery!/1 returns the grocery with given id" do
      grocery = grocery_fixture()
      assert Groceries.get_grocery!(grocery.id) == grocery
    end

    test "create_grocery/1 with valid data creates a grocery" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Grocery{} = grocery} = Groceries.create_grocery(valid_attrs)
      assert grocery.name == "some name"
    end

    test "create_grocery/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groceries.create_grocery(@invalid_attrs)
    end

    test "update_grocery/2 with valid data updates the grocery" do
      grocery = grocery_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Grocery{} = grocery} = Groceries.update_grocery(grocery, update_attrs)
      assert grocery.name == "some updated name"
    end

    test "update_grocery/2 with invalid data returns error changeset" do
      grocery = grocery_fixture()
      assert {:error, %Ecto.Changeset{}} = Groceries.update_grocery(grocery, @invalid_attrs)
      assert grocery == Groceries.get_grocery!(grocery.id)
    end

    test "delete_grocery/1 deletes the grocery" do
      grocery = grocery_fixture()
      assert {:ok, %Grocery{}} = Groceries.delete_grocery(grocery)
      assert_raise Ecto.NoResultsError, fn -> Groceries.get_grocery!(grocery.id) end
    end

    test "change_grocery/1 returns a grocery changeset" do
      grocery = grocery_fixture()
      assert %Ecto.Changeset{} = Groceries.change_grocery(grocery)
    end
  end
end
