defmodule BoodschapperWeb.GroceryLive.Show do
  use BoodschapperWeb, :live_view

  alias Boodschapper.Groceries

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:grocery, Groceries.get_grocery!(id))}
  end

  defp page_title(:show), do: "Show Grocery"
  defp page_title(:edit), do: "Edit Grocery"
end
