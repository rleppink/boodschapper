defmodule BoodschapperWeb.GroceryLive.FormComponent do
  use BoodschapperWeb, :live_component

  alias Boodschapper.Groceries

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage grocery records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="grocery-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Grocery</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{grocery: grocery} = assigns, socket) do
    changeset = Groceries.change_grocery(grocery)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"grocery" => grocery_params}, socket) do
    changeset =
      socket.assigns.grocery
      |> Groceries.change_grocery(grocery_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"grocery" => grocery_params}, socket) do
    save_grocery(socket, socket.assigns.action, grocery_params)
  end

  defp save_grocery(socket, :edit, grocery_params) do
    case Groceries.update_grocery(socket.assigns.grocery, grocery_params) do
      {:ok, grocery} ->
        notify_parent({:saved, grocery})

        {:noreply,
         socket
         |> put_flash(:info, "Grocery updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_grocery(socket, :new, grocery_params) do
    case Groceries.create_grocery(grocery_params) do
      {:ok, grocery} ->
        notify_parent({:saved, grocery})

        {:noreply,
         socket
         |> put_flash(:info, "Grocery created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
