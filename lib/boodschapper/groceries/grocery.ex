defmodule Boodschapper.Groceries.Grocery do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groceries" do
    field :name, :string
    field :checked_off, :utc_datetime

    many_to_many :tags, Boodschapper.Groceries.Tag,
      join_through: Boodschapper.Groceries.GroceriesTags

    timestamps()
  end

  @doc false
  def changeset(grocery, attrs) do
    grocery
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_assoc(:tags, attrs[:tags])
  end
end
