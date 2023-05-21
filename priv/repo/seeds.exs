# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Boodschapper.Repo.insert!(%Boodschapper.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Lidl", color: "red"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Jumbo", color: "yellow"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Albert Heijn", color: "blue"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Klussen", color: "blue"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Action", color: "blue"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Holland & Barrett", color: "blue"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Aldi", color: "blue"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Ana", color: "blue"})
Boodschapper.Repo.insert!(%Boodschapper.Groceries.Tag{name: "Kringloop", color: "blue"})
