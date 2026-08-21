defmodule Mensagem.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mensagem.User

  schema "contacts" do
    belongs_to :user, User
    belongs_to :contact, User

    timestamps()
  end

  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:user_id, :contact_id])
    |> validate_required([:user_id, :contact_id])
    |> validate_not_self()
    |> unique_constraint([:user_id, :contact_id])
    |> foreign_key_constraint(:contact_id)
  end

  defp validate_not_self(changeset) do
    user_id = get_field(changeset, :user_id)
    contact_id = get_field(changeset, :contact_id)

    if user_id && contact_id && user_id == contact_id do
      add_error(changeset, :contact_id, "cannot be the same as user")
    else
      changeset
    end
  end
end