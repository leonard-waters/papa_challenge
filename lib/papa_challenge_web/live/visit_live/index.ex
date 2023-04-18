defmodule PapaChallengeWeb.VisitLive.Index do
  use PapaChallengeWeb, :live_view

  alias PapaChallenge.{Accounts, Visits, Visits.Visit}
  alias PapaChallengeWeb.VisitLive

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    {:ok,
     stream(socket, :visits, list_visits(),
       session_id: session["live_socket_id"],
       current_user: user
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :fulfill, %{"id" => id}) do
    socket
    |> assign(:page_title, "Fulfill Visit")
    |> assign(:visit, Visits.get_visit!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Visit")
    |> assign(:visit, Visits.get_visit!(id))
  end

  defp apply_action(socket, :request, _params) do
    socket
    |> assign(:page_title, "New Visit")
    |> assign(:visit, %Visit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Visits")
    |> assign(:visit, nil)
  end

  # Update the LiveView state after submitting the Visit Request form
  @impl true
  def handle_info({VisitLive.FormComponent, {:saved, visit}}, socket) do
    {:noreply, stream_insert(socket, :visits, visit)}
  end

  # Update the LiveView state after submitting the Fulfillment form
  @impl true
  def handle_info({VisitLive.FormComponent, {:fulfilled, visit}}, socket) do
    {:noreply, stream_insert(socket, :visits, visit)}
  end

  defp list_visits() do
    Visits.list_visits()
  end
end
