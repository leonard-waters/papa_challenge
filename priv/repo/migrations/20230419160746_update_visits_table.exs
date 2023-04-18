defmodule PapaChallenge.Repo.Migrations.UpdateVisitsTable do
  use Ecto.Migration

  def change do
    alter table(:visits) do
      add :end_datetime, :naive_datetime
    end
  end
end
