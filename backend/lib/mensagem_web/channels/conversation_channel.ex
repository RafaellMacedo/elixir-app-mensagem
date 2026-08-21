defmodule MensagemWeb.ConversationChannel do
  use MensagemWeb, :channel

  alias Mensagem.Conversations

  @impl true
  def join("conversation:" <> conversation_id, _params, socket) do
    user_id = socket.assigns.current_user_id

    case Conversations.get_conversation(user_id, conversation_id) do
      nil ->
        {:error, %{reason: "unauthorized"}}

      _conversation ->
      {:ok, assign(socket, :conversation_id, conversation_id)}
    end
  end

  @impl true
  def handle_in("message", payload, socket) do
    user_id = socket.assigns.current_user_id
    conversation_id = socket.assigns.conversation_id

    case Conversations.send_message(
            user_id,
            conversation_id,
            payload["content"]
        ) do
        {:ok, message} ->
        broadcast!(socket, "message", %{
            id: message.id,
            conversation_id: message.conversation_id,
            sender_id: message.sender_id,
            content: message.content,
            inserted_at: message.inserted_at
        })

        {:reply, :ok, socket}

        {:error, :not_found} ->
        {:reply, {:error, %{reason: "unauthorized"}}, socket}

        {:error, changeset} ->
        {:reply,
        {:error,
            %{
            reason: "invalid_message",
            details:
                Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} ->
                message
                end)
            }}, socket}
    end
  end
end