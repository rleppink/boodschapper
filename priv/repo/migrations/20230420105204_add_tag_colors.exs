defmodule Boodschapper.Repo.Migrations.AddTagColors do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :color, :string, default: "yellow"
    end
  end
end
