defmodule PapaChallenge.Visits do
  @moduledoc """
  The Visits context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias PapaChallenge.Repo
  alias PapaChallenge.Accounts
  alias PapaChallenge.Visits.Visit
  alias PapaChallenge.Visits.Transactions

  @fee 0.85

  @doc """
  Returns the list of visits.

  ## Examples

      iex> list_visits()
      [%Visit{}, ...]

  """
  def list_visits do
    Repo.all(Visit)
  end

  @doc """
  Gets a single visit.

  Raises `Ecto.NoResultsError` if the Visit does not exist.

  ## Examples

      iex> get_visit!(123)
      %Visit{}

      iex> get_visit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_visit!(id), do: Repo.get!(Visit, id)

  @doc """
  Creates a visit.

  ## Examples

      iex> create_visit(%{field: value})
      {:ok, %Visit{}}

      iex> create_visit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_visit(attrs \\ %{}) do
    %Visit{}
    |> Visit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a visit.

  ## Examples

      iex> update_visit(visit, %{field: new_value})
      {:ok, %Visit{}}

      iex> update_visit(visit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_visit(%Visit{} = visit, attrs) do
    visit
    |> Visit.changeset(attrs)
    |> Repo.update()
  end

  def update_visit_on_fulfillment(%Visit{} = visit, attrs) do
    visit
    |> Visit.fulfill_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a visit.

  ## Examples

      iex> delete_visit(visit)
      {:ok, %Visit{}}

      iex> delete_visit(visit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_visit(%Visit{} = visit) do
    Repo.delete(visit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking visit changes.

  ## Examples

      iex> change_visit(visit)
      %Ecto.Changeset{data: %Visit{}}

  """
  def change_visit(%Visit{} = visit, attrs \\ %{}) do
    Visit.changeset(visit, attrs)
  end

  @doc """
  Returns a Keyword list of mappings for the tasks enum

  ## Examples

      iex> PapaChallenge.Visits.get_task_list
      [
      appointment: "appointment",
      companionship: "companionship",
      cooking: "cooking",
      errand: "errand",
      house_work: "house_work",
      laundry: "laundry",
      shopping: "shopping"
      ]
  """
  def get_task_list() do
    Ecto.Enum.mappings(Visit, :tasks)
  end

  @doc """
  Completes a visit request by updating the `end_datetime` to current time
  and updating the visit status to `fulfilled`. It then creates the transaction
  and calculates compensation for the Pal, deduction from the Member balance,
  and the overhead fee.any()

  It must be provided the Visit struct and the Pal's user_id.

  Returns :ok or {:error, %Ecto.Changeset{}}

  ## Example
      iex> Visits.fulfill_visit(%Visit{}, pal_user_id)
      :ok

      iex> Visits.fulfill_visit(%Visit{}, pal_user_id)
      {:error, %Ecto.Changeset{}}
  """
  def fulfill_visit(%Visit{} = visit, pal_id) do
    update_visit_params = %{end_datetime: NaiveDateTime.utc_now(), status: :fulfilled}

    pal = Accounts.get_user!(pal_id)
    member = Accounts.get_user!(visit.member_id)

    pal_params = %{
      balance_in_minutes: pal.balance_in_minutes + trunc(visit.minutes * @fee)
    }

    member_params = %{balance_in_minutes: member.balance_in_minutes - visit.minutes}

    transaction_params = %{member_id: visit.member_id, pal_id: pal_id}

    transaction_changeset =
      visit
      |> Ecto.build_assoc(:transaction)
      |> Transactions.change_transaction(transaction_params)

    Multi.new()
    |> Multi.insert(:transaction, transaction_changeset)
    |> Multi.update(:visit, Visit.fulfill_changeset(visit, update_visit_params))
    |> Multi.update(:member, Accounts.User.balance_changeset(member, member_params))
    |> Multi.update(:pal, Accounts.User.balance_changeset(pal, pal_params))
    |> Repo.transaction()
  end
end
