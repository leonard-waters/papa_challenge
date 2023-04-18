defmodule PapaChallengeWeb.VisitLive.Index do
  use PapaChallengeWeb, :live_view

  alias PapaChallenge.{Accounts, Visits, Visits.Visit}

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    {:ok,
     assign(socket,
       visits: list_visits(),
       session_id: session["live_socket_id"],
       current_user: user
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Visit")
    |> assign(:visit, Visits.get_visit!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Visit")
    |> assign(:visit, %Visit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Visits")
    |> assign(:visit, nil)
  end

  defp list_visits() do
    Visits.list_visits()
  end
end
