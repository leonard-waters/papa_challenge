defmodule PapaChallenge.VisitsTest do
  @moduledoc false

  use PapaChallenge.DataCase

  alias PapaChallenge.Accounts
  alias PapaChallenge.Visits
  alias PapaChallenge.Visits.Transactions

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

    test "create_visit/1 fails when balance is zero" do
      member = PapaChallenge.AccountsFixtures.user_fixture(%{balance_in_minutes: 0})
      tomorrow = NaiveDateTime.utc_now() |> NaiveDateTime.add(1, :day)

      valid_attrs = %{
        start_datetime: tomorrow,
        minutes: 60,
        status: :requested,
        tasks: [:appointment, :errand],
        member_id: member.id
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
    import PapaChallenge.VisitsFixtures

    @invalid_attrs %{
      member_id: nil,
      tasks: nil,
      start_datetime: nil,
      status: nil,
      minutes: -2
    }

    test "list_transaction/0 returns all transaction" do
      transaction = transaction_fixture()
      assert Transactions.list_transaction() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction and calculates balances correctly" do
      visit_minutes = 60

      %{minutes: visit_minutes} = member_visit = visit_fixture(%{minutes: visit_minutes})
      %{balance_in_minutes: og_pal_balance} = pal = PapaChallenge.AccountsFixtures.user_fixture()
      %{balance_in_minutes: og_mem_balance} = Accounts.get_user!(member_visit.member_id)

      assert {:ok, _} = Visits.fulfill_visit(member_visit, pal.id)
      assert %{balance_in_minutes: final_pal_balance} = Accounts.get_user!(pal.id)
      assert final_pal_balance == og_pal_balance + trunc(visit_minutes * 0.85)
      assert %{balance_in_minutes: final_mem_balance} = Accounts.get_user!(member_visit.member_id)
      assert final_mem_balance == og_mem_balance - visit_minutes
    end

    setup do
      visit_minutes = 100
      visit = visit_fixture(%{balance_in_minutes: visit_minutes, minutes: visit_minutes})
      %{visit: visit}
    end

    test "create_transaction/1 with fails to create a transaction when member balance is 0", %{
      visit: visit
    } do
      %{balance_in_minutes: og_pal_balance} = pal = PapaChallenge.AccountsFixtures.user_fixture()

      member = Accounts.get_user!(visit.member_id)

      {:ok, %{balance_in_minutes: og_mem_balance}} =
        Accounts.update_user_balance(member, %{balance_in_minutes: 0})

      assert {:error, :member, _error_changeset, %{}} = Visits.fulfill_visit(visit, pal.id)
      assert %{balance_in_minutes: final_pal_balance} = Accounts.get_user!(pal.id)
      assert final_pal_balance == og_pal_balance

      assert %{balance_in_minutes: final_mem_balance} = Accounts.get_user!(visit.member_id)
      assert final_mem_balance == og_mem_balance
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end
  end
end
