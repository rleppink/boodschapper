defmodule BoodschapperWeb.GroceryLiveTest do
  use BoodschapperWeb.ConnCase

  import Phoenix.LiveViewTest
  import Boodschapper.GroceriesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_grocery(_) do
    grocery = grocery_fixture()
    %{grocery: grocery}
  end

  describe "Index" do
    setup [:create_grocery]

    test "lists all groceries", %{conn: conn, grocery: grocery} do
      {:ok, _index_live, html} = live(conn, ~p"/groceries")

      assert html =~ "Listing Groceries"
      assert html =~ grocery.name
    end

    test "saves new grocery", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/groceries")

      assert index_live |> element("a", "New Grocery") |> render_click() =~
               "New Grocery"

      assert_patch(index_live, ~p"/groceries/new")

      assert index_live
             |> form("#grocery-form", grocery: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#grocery-form", grocery: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/groceries")

      html = render(index_live)
      assert html =~ "Grocery created successfully"
      assert html =~ "some name"
    end

    test "updates grocery in listing", %{conn: conn, grocery: grocery} do
      {:ok, index_live, _html} = live(conn, ~p"/groceries")

      assert index_live |> element("#groceries-#{grocery.id} a", "Edit") |> render_click() =~
               "Edit Grocery"

      assert_patch(index_live, ~p"/groceries/#{grocery}/edit")

      assert index_live
             |> form("#grocery-form", grocery: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#grocery-form", grocery: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/groceries")

      html = render(index_live)
      assert html =~ "Grocery updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes grocery in listing", %{conn: conn, grocery: grocery} do
      {:ok, index_live, _html} = live(conn, ~p"/groceries")

      assert index_live |> element("#groceries-#{grocery.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#groceries-#{grocery.id}")
    end
  end

  describe "Show" do
    setup [:create_grocery]

    test "displays grocery", %{conn: conn, grocery: grocery} do
      {:ok, _show_live, html} = live(conn, ~p"/groceries/#{grocery}")

      assert html =~ "Show Grocery"
      assert html =~ grocery.name
    end

    test "updates grocery within modal", %{conn: conn, grocery: grocery} do
      {:ok, show_live, _html} = live(conn, ~p"/groceries/#{grocery}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Grocery"

      assert_patch(show_live, ~p"/groceries/#{grocery}/show/edit")

      assert show_live
             |> form("#grocery-form", grocery: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#grocery-form", grocery: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/groceries/#{grocery}")

      html = render(show_live)
      assert html =~ "Grocery updated successfully"
      assert html =~ "some updated name"
    end
  end
end
