defmodule PapaChallenge.Visits.Visit do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias PapaChallenge.Accounts

  @required_fields [:start_datetime, :minutes, :tasks, :member_id]
  @status [:fulfilled, :in_progress, :requested, :scheduled]
  @tasks [:appointment, :companionship, :cooking, :errand, :house_work, :laundry, :shopping]

  schema "visits" do
    field :start_datetime, :naive_datetime
    field :end_datetime, :naive_datetime
    field :minutes, :integer, default: 0
    field :status, Ecto.Enum, values: @status, default: :requested
    field :tasks, {:array, Ecto.Enum}, values: @tasks

    belongs_to :member, PapaChallenge.Accounts.User

    has_one :transaction, PapaChallenge.Visits.Transaction

    timestamps()
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:member)
    |> validate_number(:minutes, greater_than_or_equal_to: 0)
    |> validate_start_datetime()
    |> validate_balance_in_minutes(attrs)
  end

  def fulfill_changeset(visit, attrs) do
    cast(visit, attrs, [:end_datetime, :status])
  end

  defp validate_start_datetime(changeset) do
    case get_field(changeset, :start_datetime) do
      nil ->
        Ecto.Changeset.add_error(
          changeset,
          :start_datetime,
          "The start_datetime is invalid or missing."
        )

      datetime ->
        verify_future_date(datetime, changeset)
    end
  end

  defp validate_balance_in_minutes(changeset, %{"minutes" => ""}), do: changeset

  defp validate_balance_in_minutes(changeset, %{"member_id" => member_id, "minutes" => minutes}) do
    minutes = String.to_integer(minutes)

    case Accounts.get_user!(member_id) do
      %{balance_in_minutes: balance} when balance >= minutes ->
        changeset

      %{balance_in_minutes: balance} when balance < minutes ->
        Ecto.Changeset.add_error(
          changeset,
          :minutes,
          "Requested minutes exceeds member's available balance of #{balance} minutes."
        )
    end
  end

  defp validate_balance_in_minutes(changeset, _attrs), do: changeset

  defp verify_future_date(datetime, changeset) do
    today = NaiveDateTime.utc_now()

    if NaiveDateTime.diff(datetime, today) >= 0,
      do: changeset,
      else:
        Ecto.Changeset.add_error(
          changeset,
          :start_datetime,
          "The start_datetime is invalid. It must be at least 24 hours in the future."
        )
  end
end
