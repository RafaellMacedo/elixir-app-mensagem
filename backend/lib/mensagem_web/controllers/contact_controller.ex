defmodule MensagemWeb.ContactController do
  use MensagemWeb, :controller

  alias Mensagem.Contacts

  def index(conn, _params) do
    user_id = conn.assigns.current_user_id

    contacts = Contacts.list_contacts(user_id)

    json(conn, %{
      contacts: Enum.map(contacts, &serialize_user/1)
    })
  end

  def create(conn, %{"contact_id" => contact_id}) do
    user_id = conn.assigns.current_user_id

    case Contacts.add_contact(user_id, contact_id) do
      {:ok, _contact} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "Contact added successfully"
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Unable to add contact",
          details: translate_errors(changeset)
        })
    end
  end

  def delete(conn, %{"id" => contact_id}) do
    user_id = conn.assigns.current_user_id

    case Contacts.remove_contact(user_id, contact_id) do
      {:ok, _contact} ->
        json(conn, %{
          message: "Contact removed successfully"
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          error: "Contact not found"
        })
    end
  end

  defp serialize_user(user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email
    }
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} ->
      message
    end)
  end
end