defmodule Mensagem.GroupMember do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mensagem.Group
  alias Mensagem.User

  schema "group_members" do
    belongs_to :group, Group
    belongs_to :user, User

    timestamps()
  end

  def changeset(group_member, attrs) do
    group_member
    |> cast(attrs, [:group_id, :user_id])
    |> validate_required([:group_id, :user_id])
    |> unique_constraint([:group_id, :user_id])
    |> foreign_key_constraint(:group_id)
    |> foreign_key_constraint(:user_id)
  end
end
