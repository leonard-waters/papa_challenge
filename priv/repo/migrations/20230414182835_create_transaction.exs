defmodule PapaChallenge.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def up do
    create table(:transaction) do
      add :member_id, references(:users, on_delete: :delete_all), null: false
      add :pal_id, references(:users, on_delete: :delete_all), null: false
      add :visit_id, references(:visits, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:transaction, [:member_id])
    create index(:transaction, [:pal_id])
    create index(:transaction, [:visit_id])
  end

  def down do
    drop table(:transaction)
  end
end
