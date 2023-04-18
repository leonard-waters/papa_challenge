defmodule PapaChallenge.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def up do
    create table(:visits) do
      add :start_datetime, :naive_datetime, null: false
      add :minutes, :integer, null: false
      add :status, :string
      add :tasks, {:array, :string}, null: false

      add :member_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:visits, [:member_id])
  end

  def down do
    drop table(:visits)
  end
end
