defmodule MensagemWeb.AuthController do
  use MensagemWeb, :controller

  alias Mensagem.Accounts
  alias Mensagem.Auth.Token

  def register(conn, params) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{
          id: user.id,
          name: user.name,
          email: user.email
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: format_errors(changeset)
        })
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        case Token.generate(user) do
          {:ok, token, _claims} ->
            conn
            |> put_status(:ok)
            |> json(%{
              token: token,
              user: %{
                id: user.id,
                name: user.name,
                email: user.email
              }
            })

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{
              error: "Não foi possível gerar o token",
              reason: inspect(reason)
            })
        end

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          error: "Email ou senha inválidos"
        })
    end
  end

  def me(conn, _params) do
    user_id = conn.assigns.current_user_id
    user = Accounts.get_user!(user_id)

    json(conn, %{
      user: %{
        id: user.id,
        name: user.name,
        email: user.email
      }
    })
  end
end
