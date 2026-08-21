defmodule Mensagem.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false

      add :conversation_id,
          references(:conversations, on_delete: :delete_all),
          null: false

      add :sender_id,
          references(:users, on_delete: :delete_all),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:conversation_id, :inserted_at])
    create index(:messages, [:sender_id])
  end
end