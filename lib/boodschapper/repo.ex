defmodule Boodschapper.Repo do
  use Ecto.Repo,
    otp_app: :boodschapper,
    adapter: Ecto.Adapters.SQLite3
end
