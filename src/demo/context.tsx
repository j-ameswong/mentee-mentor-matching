import { createContext, useContext } from 'react'
import type { Action, DemoState, Page, Person, Role } from './model'

export interface DemoContextValue {
  state: DemoState
  person: Person
  role: Role
  act: (action: Action, success?: string) => boolean
  navigate: (page: Page) => void
  setRole: (role: Role, page?: Page) => void
  startTour: () => void
}
export const DemoContext = createContext<DemoContextValue | null>(null)
export function useDemo() {
  const context = useContext(DemoContext)
  if (!context) throw new Error('Demo provider is missing')
  return context
}
