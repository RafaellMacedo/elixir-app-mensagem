import type { CreateGroupRequest, Group, GroupsResponse } from '../types/group'
import api from './api'

export async function listGroups(): Promise<Group[]> {
  const response = await api.get<GroupsResponse>('/groups')

  return response.data.groups
}

export async function createGroup(data: CreateGroupRequest): Promise<Group> {
  const response = await api.post<Group>('/groups', data)

  return response.data
}
