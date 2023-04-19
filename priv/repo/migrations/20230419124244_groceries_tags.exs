defmodule Boodschapper.Repo.Migrations.GroceriesTags do
  use Ecto.Migration

  def change do
    create table(:groceries_tags) do
      add :grocery_id, references(:groceries)
      add :tag_id, references(:tags)

      timestamps()
    end
  end
end
