defmodule MensagemWeb.UserSocket do
  use Phoenix.Socket

  alias Mensagem.Auth.Token

  channel "conversation:*", MensagemWeb.ConversationChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Token.verify_and_validate(token, Token.signer()) do
      {:ok, claims} ->
        user_id = claims["user_id"]

        {:ok, assign(socket, :current_user_id, user_id)}

      {:error, _reason} ->
        :error
    end
  end

  @impl true
  def connect(_params, _socket, _connect_info) do
    :error
  end

  @impl true
  def id(_socket), do: nil
end
