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
     |> stream(:tags, Groceries.list_tags())}
  end

  @impl true
  def handle_params(params, _url, socket) do
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
end
