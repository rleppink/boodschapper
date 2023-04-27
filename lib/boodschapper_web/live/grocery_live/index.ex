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
     |> assign(:groceries, Groceries.list_groceries())
     |> assign(:tags, Groceries.list_tags())
     |> assign(:selected_tags, MapSet.new())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({_, :saved, grocery}, socket) do
    {:noreply,
     socket
     |> assign(:groceries, socket.assigns.groceries ++ [grocery])
     |> assign(:tags, Groceries.list_tags())}
  end

  @impl true
  def handle_info({_, :deleted, grocery}, socket) do
    {:noreply,
     assign(
       socket,
       :groceries,
       socket.assigns.groceries |> Enum.reject(fn x -> x.id == grocery.id end)
     )}
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

    {:noreply, socket}
  end

  @impl true
  def handle_event("check", args, socket) do
    id_int = String.to_integer(args["0"])
    Groceries.check_off_grocery(id_int)

    {:noreply, socket |> assign(:groceries, Groceries.list_groceries())}
  end

  @impl true
  def handle_event("save", %{"name" => name} = _args, socket) do
    {name, hashtags} = remove_hashtags(name)

    save_grocery(socket, :new, %{
      "name" => name,
      "tags" => hashtags |> Enum.map(fn x -> %{name: x, color: "green"} end)
    })
  end

  @impl true
  def handle_event("toggle_tag", %{"0" => name}, socket) do
    updated_tags =
      if socket.assigns.selected_tags |> MapSet.member?(name) do
        socket.assigns.selected_tags |> MapSet.delete(name)
      else
        socket.assigns.selected_tags |> MapSet.put(name)
      end

    filtered_groceries =
      if Enum.any?(updated_tags) do
        Groceries.list_groceries()
        |> Enum.filter(fn grocery ->
          !MapSet.disjoint?(
            MapSet.new(grocery.grocery_tags |> Enum.map(fn x -> x.name end)),
            updated_tags
          )
        end)
      else
        Groceries.list_groceries()
      end

    {:noreply,
     socket |> assign(:selected_tags, updated_tags) |> assign(:groceries, filtered_groceries)}
  end

  defp remove_hashtags(input) do
    hashtag_pattern = ~r/#(\w+)\b/
    removed_hashtags = Regex.scan(hashtag_pattern, input) |> Enum.map(fn x -> x |> Enum.at(1) end)
    cleaned_input = String.replace(input, hashtag_pattern, "") |> String.trim()

    {cleaned_input, removed_hashtags}
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
     |> put_flash(:info, "#{grocery.name} is toegevoegd")}
  end
end
