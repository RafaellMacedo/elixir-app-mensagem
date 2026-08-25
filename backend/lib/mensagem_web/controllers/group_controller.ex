defmodule MensagemWeb.GroupController do
  use MensagemWeb, :controller

  alias Mensagem.Groups

  def index(conn, _params) do
    user_id = conn.assigns.current_user_id

    groups = Groups.list_groups(user_id)

    json(conn, %{
      groups: Enum.map(groups, &serialize_group/1)
    })
  end

  def create(conn, %{"name" => name} = params) do
    user_id = conn.assigns.current_user_id
    member_ids = Map.get(params, "member_ids", [])

    case Groups.create_group(user_id, name, member_ids) do
      {:ok, group} ->
        conn
        |> put_status(:created)
        |> json(%{
          group: %{
            id: group.id,
            name: group.name,
            creator_id: group.creator_id
          }
        })

      {:error, :member_not_contact} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "One or more members are not contacts"
        })
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Group name is required"
    })
  end

  defp serialize_group(group) do
    %{
      id: group.id,
      name: group.name,
      creator_id: group.creator_id,
      members:
        Enum.map(group.group_members, fn member ->
          %{
            id: member.user.id,
            name: member.user.name,
            email: member.user.email
          }
        end)
    }
  end
end
