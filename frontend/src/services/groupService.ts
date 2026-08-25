import api from './api'

import type { CreateGroupRequest, Group } from '../types/group'

interface GroupsResponse {
  groups: Group[]
}

interface GroupResponse {
  group: Group
}

export async function listGroups(): Promise<Group[]> {
  const response = await api.get<GroupsResponse>('/groups')

  return response.data.groups
}

export async function createGroup(data: CreateGroupRequest): Promise<Group> {
  const response = await api.post<GroupResponse>('/groups', data)

  return response.data.group
}
