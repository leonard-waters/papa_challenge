defmodule PapaChallengeWeb.VisitLive.FormComponent do
  use PapaChallengeWeb, :live_component

  alias PapaChallenge.Accounts
  alias PapaChallenge.Visits
  alias PapaChallenge.Visits.Transactions.Query, as: TransactionQuery

  @overhead 0.85

  @impl true
  def render(%{action: action} = assigns) when action in [:edit, :request] do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="visit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:minutes]} type="text" label="Minutes" required />
        <.input
          field={@form[:tasks]}
          type="select"
          multiple={true}
          label="Tasks"
          options={@task_options}
          required
        />
        <.input field={@form[:start_datetime]} type="datetime-local" label="Started At" required />
        <.input field={@form[:member_id]} type="hidden" value={@current_user.id} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Request</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def render(%{action: :fulfill} = assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form for={@form} id="visit-form" phx-target={@myself} phx-submit="fulfill">
        <:actions>
          <.button phx-disable-with="Saving...">Fulfill Request</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{visit: visit} = assigns, socket) do
    changeset = Visits.change_visit(visit)
    task_options = Visits.get_task_list()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:task_options, task_options)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset =
      socket.assigns.visit
      |> Visits.change_visit(visit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    save_visit(socket, socket.assigns.action, visit_params)
  end

  def handle_event("fulfill", _params, socket) do
    visit = socket.assigns.visit

    update_params = %{end_datetime: NaiveDateTime.utc_now(), status: :fulfilled}

    transaction_params = %{
      pal_id: socket.assigns.current_user.id,
      member_id: visit.member_id,
      visit_id: visit.id
    }

    # TODO: Refactor to a Multi Transaction in Visits context
    with {:ok, updated_visit} <-
           Visits.update_visit_on_fulfillment(visit, update_params),
         {:ok, transaction} <- TransactionQuery.create_transaction(transaction_params),
         {:ok, %{pal_compensation: pal_comp, overhead: _oh}} <-
           calculate_compensation(updated_visit),
         {:ok, _updated_pal} <- update_pal_balance(transaction.pal_id, pal_comp),
         {:ok, _updated_member} <-
           update_member_balance(updated_visit.member_id, updated_visit.minutes) do
      notify_parent({:fulfilled, updated_visit})

      {:noreply,
       socket
       |> put_flash(:info, "Visit fulfilled successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_visit(socket, :edit, params) do
    case Visits.update_visit(socket.assigns.visit, params) do
      {:ok, visit} ->
        notify_parent({:saved, visit})

        {:noreply,
         socket
         |> put_flash(:info, "Visit updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_visit(socket, :request, params) do
    params_with_user_id = Map.put(params, "member_id", socket.assigns.current_user.id)

    case Visits.create_visit(params_with_user_id) do
      {:ok, visit} ->
        notify_parent({:saved, visit})

        {:noreply,
         socket
         |> put_flash(:info, "Visit created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # This could and probably should be handled a little more elegantly
  defp calculate_compensation(%{minutes: minutes}) do
    pal_comp = round(minutes * @overhead)
    overhead = minutes - pal_comp

    {:ok, %{pal_compensation: pal_comp, overhead: overhead}}
  end

  defp update_pal_balance(pal_id, pal_compensation) do
    Accounts.update_user_balance_by_id(pal_id, pal_compensation)
  end

  defp update_member_balance(member_id, visit_minutes) do
    Accounts.update_user_balance_by_id(member_id, -visit_minutes)
  end
end
