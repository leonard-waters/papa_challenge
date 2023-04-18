defmodule PapaChallengeWeb.VisitLiveTest do
  use PapaChallengeWeb.ConnCase

  import Phoenix.LiveViewTest
  import PapaChallenge.VisitsFixtures

  @create_attrs %{
    tasks: [:appointment],
    start_datetime: NaiveDateTime.utc_now()|> NaiveDateTime.add(1, :day),
    minutes: 60
  }
  @update_attrs %{
    tasks: [:errand],
    start_datetime: NaiveDateTime.utc_now()|> NaiveDateTime.add(1, :day),
    minutes: 120
  }
  @invalid_attrs %{
    member_id: nil,
    tasks: nil,
    start_datetime: nil,
    status: nil,
    minutes: -2
  }

  defp create_visit(_) do
    visit = visit_fixture()
    %{visit: visit}
  end

  describe "Index" do
    setup [:create_visit]

    test "lists all visits", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/visits")

      assert html =~ "Listing Visits"
    end

    test "saves new visit", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/visits")

      assert index_live |> element("a", "New Visit") |> render_click() =~
               "New Visit"

      assert_patch(index_live, ~p"/visits/new")

      assert index_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#visit-form", visit: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/visits")

      html = render(index_live)
      assert html =~ "Visit created successfully"
    end

    test "updates visit in listing", %{conn: conn, visit: visit} do
      {:ok, index_live, _html} = live(conn, ~p"/visits")

      assert index_live |> element("#visits-#{visit.id} a", "Edit") |> render_click() =~
               "Edit Visit"

      assert_patch(index_live, ~p"/visits/#{visit}/edit")

      assert index_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#visit-form", visit: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/visits")

      html = render(index_live)
      assert html =~ "Visit updated successfully"
    end
  end


end
