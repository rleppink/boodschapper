defmodule Boodschapper.Groceries do
  @moduledoc """
  The Groceries context.
  """

  import Ecto.Query, warn: false
  alias Boodschapper.Repo

  alias Boodschapper.Groceries.Grocery
  alias Boodschapper.Groceries.Tag

  @doc """
  Returns the list of groceries.

  ## Examples

      iex> list_groceries()
      [%Grocery{}, ...]

  """
  def list_groceries do
    Repo.all(Grocery)
    |> Repo.preload(:grocery_tags)
  end

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single grocery.

  Raises `Ecto.NoResultsError` if the Grocery does not exist.

  ## Examples

      iex> get_grocery!(123)
      %Grocery{}

      iex> get_grocery!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grocery!(id), do: Repo.get!(Grocery, id) |> Repo.preload(:grocery_tags)

  @doc """
  Creates a grocery.
  """
  def create_grocery(%{name: name, tags: tags_list}) do
    tag_changesets = Enum.map(tags_list, fn tag -> Tag.changeset(%Tag{}, %{name: tag}) end)

    # This isn't in a transaction and can fail, but it doesn't matter:
    # - It's a small app
    # - It's only a tag that would be inserted
    tags =
      tag_changesets
      |> Enum.map(fn tag_changeset ->
        {:ok, tag} = Repo.insert(tag_changeset, on_conflict: {:replace, [:updated_at]})
        tag
      end)

    %Grocery{}
    |> Grocery.changeset(%{name: name, grocery_tags: tags})
    |> Repo.insert()
  end

  @doc """
  Updates a grocery.

  ## Examples

      iex> update_grocery(grocery, %{field: new_value})
      {:ok, %Grocery{}}

      iex> update_grocery(grocery, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grocery(%Grocery{} = grocery, attrs) do
    grocery
    |> Grocery.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a grocery.

  ## Examples

      iex> delete_grocery(grocery)
      {:ok, %Grocery{}}

      iex> delete_grocery(grocery)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grocery(%Grocery{} = grocery) do
    Repo.delete(grocery)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grocery changes.

  ## Examples

      iex> change_grocery(grocery)
      %Ecto.Changeset{data: %Grocery{}}

  """
  def change_grocery(%Grocery{} = grocery, attrs \\ %{}) do
    Grocery.changeset(grocery, attrs)
  end
end
