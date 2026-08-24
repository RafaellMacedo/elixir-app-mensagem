defmodule Mensagem.Contacts do
  import Ecto.Query

  alias Mensagem.Contact
  alias Mensagem.Repo
  alias Mensagem.User

  def list_contacts(user_id) do
    Contact
    |> where([c], c.user_id == ^user_id)
    |> join(:inner, [c], u in User, on: u.id == c.contact_id)
    |> select([c, u], u)
    |> Repo.all()
  end

  def add_contact(user_id, contact_id) do
    %Contact{}
    |> Contact.changeset(%{
      user_id: user_id,
      contact_id: contact_id
    })
    |> Repo.insert()
  end

  def remove_contact(user_id, contact_id) do
    case Repo.get_by(Contact, user_id: user_id, contact_id: contact_id) do
      nil ->
        {:error, :not_found}

      contact ->
        Repo.delete(contact)
    end
  end
end
