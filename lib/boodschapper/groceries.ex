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
  def list_groceries() do
    grocery_query =
      from g in Grocery,
        order_by: [asc: g.inserted_at],
        where: is_nil(g.checked_off)

    Repo.all(grocery_query)
    |> Repo.preload(:tags)
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
  def get_grocery!(id), do: Repo.get!(Grocery, id) |> Repo.preload(:tags)

  @doc """
  Creates a grocery.
  """
  def create_grocery(%{"name" => name, "tags" => tags_list}) do
    tag_changesets =
      Enum.map(tags_list, fn tag -> Tag.changeset(%Tag{}, %{name: tag.name, color: tag.color}) end)

    # This isn't in a transaction and can fail, but it doesn't matter:
    # - It's only a tag that would be erroneously inserted
    # - It's a small app
    tags =
      tag_changesets
      |> Enum.map(fn tag_changeset ->
        {:ok, tag} = Repo.insert(tag_changeset, on_conflict: {:replace, [:updated_at]})
        tag
      end)

    %Grocery{}
    |> Grocery.changeset(%{name: name, tags: tags})
    |> Repo.insert()
  end

  def create_tag(name, color) do
    Tag.changeset(%Tag{}, %{name: name, color: color})
    |> Repo.insert(on_conflict: {:replace, [:updated_at]})
  end

  def add_tag_to_grocery(%Grocery{tags: tags} = grocery, tag_name) do
    tag_changeset = Tag.changeset(%Tag{}, %{name: tag_name})

    {:ok, tag} = Repo.insert(tag_changeset, on_conflict: {:replace, [:updated_at]})

    grocery
    |> Grocery.changeset(%{tags: [tag | tags]})
    |> Repo.update()
  end

  def check_off_grocery(grocery_id) do
    grocery_query = from(g in Grocery, where: g.id == ^grocery_id)
    {1, nil} = Repo.update_all(grocery_query, set: [checked_off: DateTime.utc_now()])
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

  def suggest_groceries(input) do
    query = from g in Grocery, where: like(g.name, ^"%#{input}%") and g.checked_off, limit: 5
    Repo.all(query) |> Repo.preload(:tags)
  end
end
