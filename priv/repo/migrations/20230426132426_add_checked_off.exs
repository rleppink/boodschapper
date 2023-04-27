defmodule Boodschapper.Repo.Migrations.AddCheckedOff do
  use Ecto.Migration

  def change do
    alter table(:groceries) do
      add :checked_off, :utc_datetime, default: nil
    end
  end
end
