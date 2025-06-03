import type { UnknownAction } from '@reduxjs/toolkit'

export type Type = 'backend/INIT'

export interface Action extends UnknownAction {
  type: Type
}

export interface InitAction extends Action {
  type: 'backend/INIT'
}

export type State = ''

export interface BackendState {
  state: State | null
}

export const initialState: BackendState = {
  state: null,
}

type Reducer = (state: BackendState, action: UnknownAction) => BackendState

export const reducer: Reducer = (
  state = initialState,
  action: UnknownAction,
): BackendState => {
  switch ((action as Action).type) {
    case 'backend/INIT':
      return initialState
    default:
      return state
  }
}

export const actions = {
  init: (): InitAction => ({
    type: 'backend/INIT',
  })
}

export interface Store {
  backend: BackendState
}

export const selectors = {}
