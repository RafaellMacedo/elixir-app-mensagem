defmodule MensagemWeb.MessageController do
  use MensagemWeb, :controller

  alias Mensagem.Conversations

  def index(conn, %{"conversation_id" => conversation_id}) do
    user_id = conn.assigns.current_user_id

    case Conversations.list_messages(user_id, conversation_id) do
      {:ok, messages} ->
        json(conn, %{
          messages: Enum.map(messages, &serialize_message/1)
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          error: "Conversation not found"
        })
    end
  end

  def create(conn, %{
        "conversation_id" => conversation_id,
        "content" => content
      }) do
    user_id = conn.assigns.current_user_id

    case Conversations.send_message(user_id, conversation_id, content) do
      {:ok, message} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: serialize_message(message)
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          error: "Conversation not found"
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Unable to send message",
          details: translate_errors(changeset)
        })
    end
  end

  defp serialize_message(message) do
    %{
      id: message.id,
      conversation_id: message.conversation_id,
      sender_id: message.sender_id,
      content: message.content,
      inserted_at: message.inserted_at
    }
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} ->
      message
    end)
  end
end