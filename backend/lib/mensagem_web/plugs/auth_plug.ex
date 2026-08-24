defmodule MensagemWeb.AuthPlug do
  import Plug.Conn

  alias Mensagem.Auth.Token

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        authenticate(conn, token)

      _ ->
        unauthorized(conn)
    end
  end

  defp authenticate(conn, token) do
    case Token.verify_and_validate(token, Token.signer()) do
      {:ok, claims} ->
        assign(conn, :current_user_id, claims["user_id"])

      {:error, _reason} ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(%{
      error: "Não autorizado"
    })
    |> halt()
  end
end
