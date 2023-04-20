defmodule Boodschapper.Groceries.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    # Color as in Tailwind color. i.e. "red", "yellow", "green", etc.
    field :color, :string

    many_to_many :grocery, Boodschapper.Groceries.Grocery,
      join_through: Boodschapper.Groceries.GroceriesTags

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :color])
    |> validate_required([:name, :color])
  end
end
