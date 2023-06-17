defmodule BoodschapperWeb.MyComponents do
  use Phoenix.Component

  attr :name, :string, required: true
  attr :color, :string, required: true
  attr :rest, :global

  def tag(assigns) do
    ~H"""
    <span
      class={"px-2 border rounded-full
                    border-#{@color}-500
                    bg-#{@color}-100"}
      {@rest}
    >
      <%= @name %>
    </span>
    """
  end
end
