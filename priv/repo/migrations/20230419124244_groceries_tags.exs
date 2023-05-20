defmodule Boodschapper.Repo.Migrations.GroceriesTags do
  use Ecto.Migration

  def change do
    create table(:groceries_tags) do
      add :grocery_id, references(:groceries, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: delete_all), null: false

      timestamps()
    end

    create unique_index(:groceries_tags, [:grocery_id, :tag_id])
  end
end
