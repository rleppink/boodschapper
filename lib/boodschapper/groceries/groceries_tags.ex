defmodule Boodschapper.Groceries.GroceriesTags do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groceries_tags" do
    belongs_to(:grocery, Boodschapper.Groceries.Grocery)
    belongs_to(:tag, Boodschapper.Groceries.Tag)

    timestamps()
  end

  @doc false
  def changeset(groceries_tags, attrs) do
    groceries_tags
    |> cast(attrs, [:grocery_id, :tag_id])
    |> validate_required([:grocery_id, :tag_id])
  end
end
