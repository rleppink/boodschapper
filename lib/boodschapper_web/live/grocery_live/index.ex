defmodule BoodschapperWeb.GroceryLive.Index do
  use BoodschapperWeb, :live_view

  alias Boodschapper.Groceries

  @topic inspect(__MODULE__)

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Boodschapper.PubSub, @topic)

    {:ok,
     socket
     |> assign(:page_title, "🛒 Boodschappen")
     |> stream(:groceries, Groceries.list_groceries())
     |> assign(:tags, tags_with_selections())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({BoodschapperWeb.GroceryLive.FormComponent, {:saved, grocery}}, socket) do
    Phoenix.PubSub.broadcast(
      Boodschapper.PubSub,
      @topic,
      {Boodschapper.PubSub, :saved, grocery}
    )

    {:noreply, stream_insert(socket, :groceries, grocery)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    grocery = Groceries.get_grocery!(id)
    {:ok, _} = Groceries.delete_grocery(grocery)

    Phoenix.PubSub.broadcast(
      Boodschapper.PubSub,
      @topic,
      {Boodschapper.PubSub, :deleted, grocery}
    )

    {:noreply, stream_delete(socket, :groceries, grocery)}
  end

  @impl true
  def handle_event("save", args, socket) do
    save_grocery(socket, :new, args)
  end

  @impl true
  def handle_event("select_tag", %{"0" => name}, socket) do
    updated_tags =
      update_in(
        socket.assigns.tags,
        [Access.filter(fn tag -> tag.name == name end)],
        fn tag -> Map.put(tag, :selected, !tag.selected) end
      )

    {:noreply, socket |> assign(:tags, updated_tags)}
  end

  defp save_grocery(socket, :new, grocery_params) do
    {:ok, grocery} = Groceries.create_grocery(grocery_params)

    Phoenix.PubSub.broadcast(
      Boodschapper.PubSub,
      @topic,
      {Boodschapper.PubSub, :saved, grocery}
    )

    Process.send_after(self(), :clear_flash, 2000)

    {:noreply,
     socket
     |> stream_insert(:groceries, grocery)
     |> put_flash(:info, "#{grocery.name} is toegevoegd")}
  end

  defp tags_with_selections do
    Groceries.list_tags()
    |> Enum.map(fn tag ->
      Map.put(tag, :selected, false)
    end)
  end
end
