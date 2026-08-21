defmodule Mensagem.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :type, :string, null: false
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create index(:conversations, [:type])
  end
end