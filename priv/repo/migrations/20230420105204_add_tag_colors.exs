defmodule Boodschapper.Repo.Migrations.AddTagColors do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :color, :string, default: "gray"
    end
  end
end
