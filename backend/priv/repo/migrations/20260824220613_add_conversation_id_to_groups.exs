defmodule Mensagem.Repo.Migrations.AddConversationIdToGroups do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :conversation_id, references(:conversations, on_delete: :delete_all)
    end

    create unique_index(:groups, [:conversation_id])
  end
end
