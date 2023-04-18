defmodule PapaChallenge.Visits.Visit do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:start_datetime, :minutes, :tasks, :member_id]
  @status [:fulfilled, :in_progress, :requested, :scheduled]
  @tasks [:appointment, :companionship, :cooking, :errand, :house_work, :laundry, :shopping]

  schema "visits" do
    field :start_datetime, :naive_datetime
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
    |> validate_date_in_future()
  end

  defp validate_date_in_future(changeset) do
    case get_field(changeset, :start_datetime) do
      nil ->
        Ecto.Changeset.add_error(changeset, :start_datetime, "The start_datetime is invalid.")

      date ->
        today = NaiveDateTime.utc_now()

        if NaiveDateTime.diff(date, today) >= 0,
          do: changeset,
          else:
            Ecto.Changeset.add_error(
              changeset,
              :start_datetime,
              "The start_datetime is invalid. It must be at least 24 hours in the future."
            )
    end
  end
end
