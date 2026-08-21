defmodule Mensagem.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mensagem.Contact

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string

    has_many :contacts, Contact
    has_many :contact_users, through: [:contacts, :contact]

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash])
    |> validate_required([:name, :email, :password_hash])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
  end
end
