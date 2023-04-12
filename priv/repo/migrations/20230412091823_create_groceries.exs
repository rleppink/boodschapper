defmodule Boodschapper.Repo.Migrations.CreateGroceries do
  use Ecto.Migration

  def change do
    create table(:groceries) do
      add :name, :string

      timestamps()
    end
  end
end
