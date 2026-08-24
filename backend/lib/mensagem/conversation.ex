defmodule Mensagem.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mensagem.Message
  alias Mensagem.ConversationParticipant
  alias Mensagem.Group

  schema "conversations" do
    field :type, :string
    field :name, :string

    belongs_to :group, Group

    has_many :participants, ConversationParticipant
    has_many :users, through: [:participants, :user]
    has_many :messages, Message

    timestamps(type: :utc_datetime)
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:type, :name, :group_id])
    |> validate_required([:type])
    |> validate_inclusion(:type, ["private", "group"])
  end
end
