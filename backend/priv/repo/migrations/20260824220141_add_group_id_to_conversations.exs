defmodule Mensagem.Repo.Migrations.AddGroupIdToConversations do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add :group_id, references(:groups, on_delete: :delete_all)
    end

    create index(:conversations, [:group_id])
    create unique_index(:conversations, [:group_id])
  end
end
