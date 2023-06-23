defmodule BoodschapperWeb.GroceryLive.Index do
  use BoodschapperWeb, :live_view

  import BoodschapperWeb.MyComponents

  alias Boodschapper.Groceries

  @topic inspect(__MODULE__)

  # This is not the right place, and doubly defined (also in tailwind.config.js)
  @colors [
    "red",
    "orange",
    "yellow",
    "green",
    "teal",
    "blue",
    "indigo",
    "purple",
    "pink",
    "gray"
  ]

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Boodschapper.PubSub, @topic)

    {:ok,
     socket
     |> assign(:page_title, "🛒 Boodschappen")
     |> assign(:groceries, Groceries.list_groceries())
     |> assign(:tags, Groceries.list_tags())
     |> assign(:selected_tags, MapSet.new())
     |> assign(:suggestions, [])
     |> assign(:colors, @colors)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({Boodschapper.PubSub, :saved}, socket) do
    {:noreply,
     socket
     |> assign(:groceries, Groceries.list_groceries())
     |> assign(:tags, Groceries.list_tags())}
  end

  @impl true
  def handle_info({_, :checked_off}, socket) do
    {:noreply,
     socket
     |> assign(:groceries, Groceries.list_groceries())}
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
  def handle_event("get_suggestions", %{"name" => ""} = _args, socket) do
    {:noreply, socket |> assign(:suggestions, [])}
  end

  @impl true
  def handle_event("get_suggestions", %{"name" => name} = _args, socket) do
    suggestions = Groceries.suggest_groceries(name)
    {:noreply, socket |> assign(:suggestions, suggestions)}
  end

  @impl true
  def handle_event("check", args, socket) do
    id_int = String.to_integer(args["0"])
    Groceries.check_off_grocery(id_int)

    Phoenix.PubSub.broadcast(
      Boodschapper.PubSub,
      @topic,
      {Boodschapper.PubSub, :checked_off}
    )

    {:noreply, socket |> assign(:groceries, Groceries.list_groceries())}
  end

  @impl true
  def handle_event("save_suggestion", %{"name" => name, "tag_ids" => tag_ids}, socket) do
    Groceries.add_suggestion(name, tag_ids |> Jason.decode!())

    {:noreply,
     socket |> assign(:suggestions, []) |> assign(:groceries, Groceries.list_groceries())}
  end

  @impl true
  def handle_event("save", %{"name" => name} = _args, socket) do
    {:ok, grocery} =
      Groceries.create_grocery(%{
        "name" => name,
        "tags" =>
          socket.assigns.selected_tags
          |> MapSet.to_list()
          |> Enum.map(fn x -> %{name: x, color: "green"} end)
      })

    Phoenix.PubSub.broadcast(
      Boodschapper.PubSub,
      @topic,
      {Boodschapper.PubSub, :saved}
    )

    Process.send_after(self(), :clear_flash, 2000)

    {:noreply,
     socket
     |> put_flash(:info, "#{grocery.name} is toegevoegd")}
  end

  @impl true
  def handle_event("toggle_tag", %{"0" => name}, socket) do
    updated_tags =
      if socket.assigns.selected_tags |> MapSet.member?(name) do
        socket.assigns.selected_tags |> MapSet.delete(name)
      else
        socket.assigns.selected_tags |> MapSet.put(name)
      end

    {:noreply,
     socket
     |> assign(:selected_tags, updated_tags)}
  end

  @impl true
  def handle_event(
        "toggle_grocery_tag",
        %{"grocery-id" => grocery_id, "tag-id" => tag_id},
        socket
      ) do
    Groceries.toggle_grocery_tag(grocery_id |> String.to_integer(), tag_id |> String.to_integer())
    {:noreply, socket |> assign(:groceries, Groceries.list_groceries())}
  end

  @impl true
  def handle_event("add_tag", %{"tag_name" => tag_name}, socket) do
    {:ok, _} = Groceries.create_tag(tag_name, "green")

    {:noreply, socket |> assign(:tags, Groceries.list_tags())}
  end

  defp filtered_groceries(groceries, %MapSet{map: map}) when map_size(map) == 0, do: groceries

  defp filtered_groceries(groceries, selected_tags) do
    groceries
    |> Enum.filter(fn grocery ->
      not MapSet.disjoint?(
        MapSet.new(grocery.tags |> Enum.map(fn x -> x.name end)),
        selected_tags
      )
    end)
  end
end
