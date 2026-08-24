export interface GroupMember {
  id: number
  name: string
  email: string
}

export interface Group {
  id: number
  name: string
  creator_id: number
  members: GroupMember[]
}

export interface CreateGroupRequest {
  name: string
  member_ids: number[]
}
