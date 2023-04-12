defmodule Boodschapper.Groceries.Grocery do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groceries" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(grocery, attrs) do
    grocery
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
