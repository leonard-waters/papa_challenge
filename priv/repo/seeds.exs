# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PapaChallenge.Repo.insert!(%PapaChallenge.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias PapaChallenge.{Accounts, Visits, Visits.Transactions.Query}

{:ok, pal} =
  Accounts.register_user(%{
    email: "pal@test.com",
    first_name: "pal",
    last_name: "test",
    password: "passwordtest",
    balance_in_minutes: 60
  })
  |> IO.inspect()

{:ok, member} =
  Accounts.register_user(%{
    email: "member@test.com",
    first_name: "member",
    last_name: "test",
    password: "passwordtest",
    balance_in_minutes: 0
  })
  |> IO.inspect()

{:ok, member_pal} =
  Accounts.register_user(%{
    email: "memberpal@test.com",
    first_name: "memberpal",
    last_name: "test",
    password: "passwordtest",
    balance_in_minutes: 120
  })
  |> IO.inspect()

  Visits.create_visit(%{
    member_id: member_pal.id,
    tasks: [:appointment],
    start_datetime: NaiveDateTime.utc_now()|> NaiveDateTime.add(1, :day),
    status: :requested,
    minutes: 60
  })
  |> IO.inspect()

{:ok, fulfilled_visit} =
  Visits.create_visit(%{
    member_id: member.id,
    tasks: [:errand],
    start_datetime: NaiveDateTime.utc_now() |> NaiveDateTime.add(1, :day),
    status: :fulfilled,
    minutes: 60,
    end_datetime: NaiveDateTime.utc_now() |> NaiveDateTime.add(2, :day)
  })
  |> IO.inspect()

Query.create_transaction(%{
  member_id: member.id,
  pal_id: pal.id,
  visit_id: fulfilled_visit.id
})
|> IO.inspect()
