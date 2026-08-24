defmodule Mensagem.ConversationParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mensagem.Conversation
  alias Mensagem.User

  schema "conversation_participants" do
    belongs_to :conversation, Conversation
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:conversation_id, :user_id])
    |> validate_required([:conversation_id, :user_id])
    |> unique_constraint([:conversation_id, :user_id])
  end
end
