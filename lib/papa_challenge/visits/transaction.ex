defmodule PapaChallenge.Visits.Transaction do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:member_id, :pal_id, :visit_id]

  schema "transaction" do
    belongs_to :member, PapaChallenge.Accounts.User
    belongs_to :pal, PapaChallenge.Accounts.User
    belongs_to :visit, PapaChallenge.Visits.Visit

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:member)
    |> assoc_constraint(:pal)
    |> assoc_constraint(:visit)
  end
end
