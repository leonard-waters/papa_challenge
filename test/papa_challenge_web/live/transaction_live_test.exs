defmodule PapaChallengeWeb.TransactionLiveTest do
  use PapaChallengeWeb.ConnCase

  import Phoenix.LiveViewTest
  import PapaChallenge.VisitsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_transaction(_) do
    transaction = transaction_fixture()
    %{transaction: transaction}
  end

  describe "Index" do
    setup [:create_transaction]

    test "lists all transaction", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/transaction")

      assert html =~ "Listing Transaction"
    end

    test "saves new transaction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/transaction")

      assert index_live |> element("a", "New Transaction") |> render_click() =~
               "New Transaction"

      assert_patch(index_live, ~p"/transaction/new")

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transaction-form", transaction: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transaction")

      html = render(index_live)
      assert html =~ "Transaction created successfully"
    end

    test "updates transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, ~p"/transaction")

      assert index_live |> element("#transaction-#{transaction.id} a", "Edit") |> render_click() =~
               "Edit Transaction"

      assert_patch(index_live, ~p"/transaction/#{transaction}/edit")

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transaction-form", transaction: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transaction")

      html = render(index_live)
      assert html =~ "Transaction updated successfully"
    end

    test "deletes transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, ~p"/transaction")

      assert index_live |> element("#transaction-#{transaction.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#transaction-#{transaction.id}")
    end
  end

  describe "Show" do
    setup [:create_transaction]

    test "displays transaction", %{conn: conn, transaction: transaction} do
      {:ok, _show_live, html} = live(conn, ~p"/transaction/#{transaction}")

      assert html =~ "Show Transaction"
    end

    test "updates transaction within modal", %{conn: conn, transaction: transaction} do
      {:ok, show_live, _html} = live(conn, ~p"/transaction/#{transaction}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Transaction"

      assert_patch(show_live, ~p"/transaction/#{transaction}/show/edit")

      assert show_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#transaction-form", transaction: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/transaction/#{transaction}")

      html = render(show_live)
      assert html =~ "Transaction updated successfully"
    end
  end
end
