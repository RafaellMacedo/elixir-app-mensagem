defmodule Mensagem.Conversations do
  import Ecto.Query

  alias Mensagem.Contact
  alias Mensagem.Conversation
  alias Mensagem.ConversationParticipant
  alias Mensagem.Message
  alias Mensagem.Repo

  def create_private_conversation(user_id, contact_id) do
    with :ok <- validate_contact(user_id, contact_id),
         {:ok, conversation} <- find_or_create_conversation(user_id, contact_id) do
      {:ok, conversation}
    end
  end

  def list_conversations(user_id) do
    Conversation
    |> join(:inner, [c], p in ConversationParticipant,
      on: p.conversation_id == c.id
    )
    |> where([c, p], p.user_id == ^user_id)
    |> order_by([c], desc: c.updated_at)
    |> Repo.all()
  end

  def get_conversation(user_id, conversation_id) do
    Conversation
    |> join(:inner, [c], p in ConversationParticipant,
      on: p.conversation_id == c.id
    )
    |> where(
      [c, p],
      c.id == ^conversation_id and p.user_id == ^user_id
    )
    |> Repo.one()
  end

  def list_messages(user_id, conversation_id) do
    case get_conversation(user_id, conversation_id) do
        nil ->
        {:error, :not_found}

        conversation ->
        messages =
            Message
            |> where([m], m.conversation_id == ^conversation.id)
            |> order_by([m], asc: m.inserted_at)
            |> Repo.all()

        {:ok, messages}
    end
  end

  def send_message(user_id, conversation_id, content) do
    case get_conversation(user_id, conversation_id) do
        nil ->
        {:error, :not_found}

        conversation ->
        %Message{}
        |> Message.changeset(%{
            conversation_id: conversation.id,
            sender_id: user_id,
            content: content
        })
        |> Repo.insert()
    end
  end

  defp validate_contact(user_id, contact_id) do
    cond do
      user_id == contact_id ->
        {:error, :cannot_create_conversation_with_self}

      Repo.exists?(
        from c in Contact,
          where: c.user_id == ^user_id and c.contact_id == ^contact_id
      ) ->
        :ok

      true ->
        {:error, :not_a_contact}
    end
  end

  defp find_or_create_conversation(user_id, contact_id) do
    case find_private_conversation(user_id, contact_id) do
      nil ->
        create_conversation(user_id, contact_id)

      conversation ->
        {:ok, conversation}
    end
  end

  defp find_private_conversation(user_id, contact_id) do
    Conversation
    |> where([c], c.type == "private")
    |> join(:inner, [c], p1 in ConversationParticipant,
      on: p1.conversation_id == c.id and p1.user_id == ^user_id
    )
    |> join(:inner, [c, p1], p2 in ConversationParticipant,
      on: p2.conversation_id == c.id and p2.user_id == ^contact_id
    )
    |> Repo.one()
  end

  defp create_conversation(user_id, contact_id) do
    Repo.transaction(fn ->
      {:ok, conversation} =
        %Conversation{}
        |> Conversation.changeset(%{type: "private"})
        |> Repo.insert()

      {:ok, _participant} =
        %ConversationParticipant{}
        |> ConversationParticipant.changeset(%{
          conversation_id: conversation.id,
          user_id: user_id
        })
        |> Repo.insert()

      {:ok, _participant} =
        %ConversationParticipant{}
        |> ConversationParticipant.changeset(%{
          conversation_id: conversation.id,
          user_id: contact_id
        })
        |> Repo.insert()

      conversation
    end)
  end
end