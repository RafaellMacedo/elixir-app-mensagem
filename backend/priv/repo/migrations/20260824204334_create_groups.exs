defmodule Mensagem.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string, null: false
      add :creator_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:groups, [:creator_id])
  end
end