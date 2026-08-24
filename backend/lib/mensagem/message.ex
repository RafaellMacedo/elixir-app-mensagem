defmodule Mensagem.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mensagem.Conversation
  alias Mensagem.User

  schema "messages" do
    field :content, :string

    belongs_to :conversation, Conversation
    belongs_to :sender, User

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :conversation_id, :sender_id])
    |> validate_required([:content, :conversation_id, :sender_id])
    |> validate_length(:content, min: 1, max: 5000)
  end
end
