defmodule Mensagem.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mensagem.User
  alias Mensagem.GroupMember

  schema "groups" do
    field :name, :string

    belongs_to :creator, User
    has_many :group_members, GroupMember

    timestamps()
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :creator_id])
    |> validate_required([:name, :creator_id])
    |> validate_length(:name, min: 1, max: 100)
    |> foreign_key_constraint(:creator_id)
  end
end
