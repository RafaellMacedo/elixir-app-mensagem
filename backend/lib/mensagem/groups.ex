defmodule Mensagem.Groups do
  alias Mensagem.Contact
  alias Mensagem.Group
  alias Mensagem.GroupMember
  alias Mensagem.Repo

  import Ecto.Query

  def list_groups(user_id) do
    Group
    |> join(:inner, [g], gm in GroupMember, on: gm.group_id == g.id)
    |> where([g, gm], gm.user_id == ^user_id)
    |> preload(group_members: :user)
    |> order_by([g, _gm], desc: g.inserted_at)
    |> Repo.all()
  end

  def create_group(user_id, name, member_ids) do
    Repo.transaction(fn ->
      group =
        %Group{}
        |> Group.changeset(%{
          name: name,
          creator_id: user_id
        })
        |> Repo.insert!()

      add_member!(group.id, user_id)

      Enum.each(member_ids, fn member_id ->
        if is_contact?(user_id, member_id) do
          add_member!(group.id, member_id)
        else
          Repo.rollback(:member_not_contact)
        end
      end)

      group
    end)
  end

  defp is_contact?(user_id, contact_id) do
    Contact
    |> where([c], c.user_id == ^user_id and c.contact_id == ^contact_id)
    |> Repo.exists?()
  end

  defp add_member!(group_id, user_id) do
    %GroupMember{}
    |> GroupMember.changeset(%{
      group_id: group_id,
      user_id: user_id
    })
    |> Repo.insert!()
  end
end
