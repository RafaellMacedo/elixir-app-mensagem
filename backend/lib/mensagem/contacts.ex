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

  def list_available_users(user_id) do
    User
    |> where([u], u.id != ^user_id)
    |> where(
      [u],
      u.id not in subquery(
        from c in Contact,
          where: c.user_id == ^user_id,
          select: c.contact_id
      )
    )
    |> Repo.all()
  end
end
