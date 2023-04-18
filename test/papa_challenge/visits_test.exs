defmodule PapaChallenge.VisitsTest do
  @moduledoc false

  use PapaChallenge.DataCase

  alias PapaChallenge.Visits

  describe "visits" do
    alias PapaChallenge.Visits.Visit

    import PapaChallenge.VisitsFixtures

    @invalid_attrs %{
      start_datetime: nil,
      minutes: nil,
      status: nil,
      tasks: nil,
      member_id: nil
    }

    test "list_visits/0 returns all visits" do
      visit = visit_fixture()

      assert Visits.list_visits() == [visit]
    end

    test "get_visit!/1 returns the visit with given id" do
      visit = visit_fixture()
      assert Visits.get_visit!(visit.id) == visit
    end

    test "create_visit/1 with valid data creates a visit" do
      user = PapaChallenge.AccountsFixtures.user_fixture()
      future_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(2, :day)

      valid_attrs = %{
        start_datetime: future_datetime,
        minutes: 0,
        status: :requested,
        tasks: [:appointment, :errand],
        member_id: user.id
      }

      assert {:ok, %Visit{} = _visit} = Visits.create_visit(valid_attrs)
    end

    test "create_visit/1 fails when start_datetime is previous day" do
      user = PapaChallenge.AccountsFixtures.user_fixture()
      yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1, :day)

      valid_attrs = %{
        start_datetime: yesterday,
        minutes: 0,
        status: :requested,
        tasks: [:appointment, :errand],
        member_id: user.id
      }

      assert {:error, %Ecto.Changeset{}} = Visits.create_visit(valid_attrs)
    end

    test "create_visit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Visits.create_visit(@invalid_attrs)
    end

    test "update_visit/2 with valid data updates the visit" do
      visit = visit_fixture()
      future_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(5, :day)

      update_attrs = %{
        start_datetime: future_datetime,
        status: :requested,
        tasks: [:appointment]
      }

      assert {:ok, %Visit{} = _visit} = Visits.update_visit(visit, update_attrs)
    end

    test "update_visit/2 with invalid data returns error changeset" do
      visit = visit_fixture()
      assert {:error, %Ecto.Changeset{}} = Visits.update_visit(visit, @invalid_attrs)
      assert visit == Visits.get_visit!(visit.id)
    end

    test "delete_visit/1 deletes the visit" do
      visit = visit_fixture()
      assert {:ok, %Visit{}} = Visits.delete_visit(visit)
      assert_raise Ecto.NoResultsError, fn -> Visits.get_visit!(visit.id) end
    end

    test "change_visit/1 returns a visit changeset" do
      visit = visit_fixture()
      assert %Ecto.Changeset{} = Visits.change_visit(visit)
    end
  end

  describe "transaction" do
    alias PapaChallenge.Visits.Transaction

    import PapaChallenge.VisitsFixtures

    @invalid_attrs %{}

    test "list_transaction/0 returns all transaction" do
      transaction = transaction_fixture()
      assert Visits.list_transaction() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Visits.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      member_visit = visit_fixture()
      pal = PapaChallenge.AccountsFixtures.user_fixture(%{email: "test@example.com"})

      valid_attrs = %{
        member_id: member_visit.member_id,
        pal_id: pal.id,
        visit_id: member_visit.id
      }

      assert {:ok, %Transaction{} = _transaction} = Visits.create_transaction(valid_attrs)
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Visits.create_transaction(@invalid_attrs)
    end
  end
end
