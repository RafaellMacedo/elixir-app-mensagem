defmodule MensagemWeb.ConversationController do
  use MensagemWeb, :controller

  alias Mensagem.Conversations

  def index(conn, _params) do
    user_id = conn.assigns.current_user_id

    conversations = Conversations.list_conversations(user_id)

    json(conn, %{
      conversations: Enum.map(conversations, &serialize_conversation/1)
    })
  end

  def create(conn, %{"contact_id" => contact_id}) do
    user_id = conn.assigns.current_user_id

    case Conversations.create_private_conversation(user_id, contact_id) do
      {:ok, conversation} ->
        conn
        |> put_status(:created)
        |> json(%{
          conversation: serialize_conversation(conversation)
        })

      {:error, :not_a_contact} ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          error: "User is not in your contacts"
        })

      {:error, :cannot_create_conversation_with_self} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Cannot create a conversation with yourself"
        })

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Unable to create conversation",
          reason: inspect(reason)
        })
    end
  end

  def show(conn, %{"id" => conversation_id}) do
    user_id = conn.assigns.current_user_id

    case Conversations.get_conversation(user_id, conversation_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{
          error: "Conversation not found"
        })

      conversation ->
        json(conn, %{
          conversation: serialize_conversation(conversation)
        })
    end
  end

  defp serialize_conversation(conversation) do
    %{
      id: conversation.id,
      type: conversation.type,
      name: conversation.name,
      inserted_at: conversation.inserted_at,
      updated_at: conversation.updated_at
    }
  end
end
