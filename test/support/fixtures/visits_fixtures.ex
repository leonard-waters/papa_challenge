defmodule PapaChallenge.VisitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PapaChallenge.Visits` context.
  """

  @doc """
  Generate a visit and the prerequisite member.
  """
  def visit_fixture(attrs \\ %{}) do
    user = PapaChallenge.AccountsFixtures.user_fixture(attrs)
    future_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(2, :day)

    {:ok, visit} =
      Enum.into(attrs, %{
        start_datetime: future_datetime,
        minutes: 60,
        status: :requested,
        tasks: [:appointment, :errand],
        member_id: user.id
      })
      |> PapaChallenge.Visits.create_visit()

    visit
  end

  @doc """
  Generate a transaction and the prerequisite member, pal, and requested visit.
  """
  def transaction_fixture(attrs \\ %{}) do
    member_visit = visit_fixture()
    pal = PapaChallenge.AccountsFixtures.user_fixture(%{email: "pal@example.com"})

    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        member_id: member_visit.member_id,
        pal_id: pal.id,
        visit_id: member_visit.id
      })
      |> PapaChallenge.Visits.Transactions.create_transaction()

    transaction
  end
end
