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
  def handle_info({_, :saved, grocery}, socket) do
    {:noreply, stream_insert(socket, :groceries, grocery)}
  end

  @impl true
  def handle_info({_, :deleted, grocery}, socket) do
    {:noreply, stream_delete(socket, :groceries, grocery)}
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
  def handle_event("save", %{"name" => name} = _args, socket) do
    {name, hashtags} = remove_hashtags(name) |> IO.inspect(label: "hashtags")

    save_grocery(socket, :new, %{
      "name" => name,
      "tags" => hashtags |> Enum.map(fn x -> %{name: x, color: "green"} end)
    })
  end

  defp remove_hashtags(input) do
    hashtag_pattern = ~r/#(\w+)\b/
    removed_hashtags = Regex.scan(hashtag_pattern, input) |> Enum.map(fn x -> x |> Enum.at(1) end)
    cleaned_input = String.replace(input, hashtag_pattern, "") |> String.trim()

    {cleaned_input, removed_hashtags}
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
    selected_tags =
      socket.assigns.tags
      |> Enum.filter(& &1.selected)

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
     |> assign(:tags, tags_with_selections())
     |> put_flash(:info, "#{grocery.name} is toegevoegd")}
  end

  defp tags_with_selections do
    Groceries.list_tags()
    |> Enum.map(fn tag ->
      Map.put(tag, :selected, false)
    end)
  end
end
