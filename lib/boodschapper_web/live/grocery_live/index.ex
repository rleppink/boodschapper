defmodule BoodschapperWeb.GroceryLive.Index do
  use BoodschapperWeb, :live_view

  alias Boodschapper.Groceries
  alias Boodschapper.Groceries.Grocery

  @topic inspect(__MODULE__)

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Boodschapper.PubSub, @topic)

    {:ok, stream(socket, :groceries, Groceries.list_groceries())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Grocery")
    |> assign(:grocery, Groceries.get_grocery!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Grocery")
    |> assign(:grocery, %Grocery{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Groceries")
    |> assign(:grocery, nil)
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

  @impl true
  def handle_info({Boodschapper.PubSub, :saved, grocery}, socket) do
    {:noreply, stream_insert(socket, :groceries, grocery)}
  end

  @impl true
  def handle_info({Boodschapper.PubSub, :deleted, grocery}, socket) do
    {:noreply, stream_delete(socket, :groceries, grocery)}
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
end
