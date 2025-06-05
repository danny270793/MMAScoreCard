import type { UnknownAction } from '@reduxjs/toolkit'
import type { Event } from '../models/event'

export type Type =
  | 'backend/INIT'
  | 'backend/CLEAR_ERROR'
  | 'backend/GET_EVENTS'
  | 'backend/GET_EVENTS_SUCCESS'
  | 'backend/GET_EVENTS_ERROR'

export interface Action extends UnknownAction {
  type: Type
}

export interface InitAction extends Action {
  type: 'backend/INIT'
}

export interface ClearErrorAction extends Action {
  type: 'backend/CLEAR_ERROR'
}

export interface GetEventsAction extends Action {
  type: 'backend/GET_EVENTS'
}

export interface GetEventsSuccessAction extends Action {
  type: 'backend/GET_EVENTS_SUCCESS'
  events: Event[]
}

export interface GetEventsErrorAction extends Action {
  type: 'backend/GET_EVENTS_ERROR'
  error: Error
}

export type State =
  | 'initting'
  | 'getting_events'
  | 'getting_events_success'
  | 'getting_events_error'

export interface BackendState {
  state: State
  error: Error | undefined
  events: Event[]
}

export const initialState: BackendState = {
  state: 'initting',
  error: undefined,
  events: [],
}

type Reducer = (state: BackendState, action: UnknownAction) => BackendState

export const reducer: Reducer = (
  state = initialState,
  action: UnknownAction,
): BackendState => {
  switch ((action as Action).type) {
    case 'backend/INIT':
      return initialState
    case 'backend/CLEAR_ERROR':
      return { ...state, state: 'initting', error: undefined }
    case 'backend/GET_EVENTS':
      return {
        ...state,
        state: 'getting_events',
        error: undefined,
      }
    case 'backend/GET_EVENTS_SUCCESS':
      return {
        ...state,
        state: 'getting_events_success',
        events: (action as GetEventsSuccessAction).events,
      }
    case 'backend/GET_EVENTS_ERROR':
      return {
        ...state,
        state: 'getting_events_error',
        error: (action as GetEventsErrorAction).error,
      }
    default:
      return state
  }
}

export const actions = {
  init: (): InitAction => ({
    type: 'backend/INIT',
  }),
  clearError: (): ClearErrorAction => ({
    type: 'backend/CLEAR_ERROR',
  }),
  getEvents: (): GetEventsAction => ({
    type: 'backend/GET_EVENTS',
  }),
  getEventsSuccess: (events: Event[]): GetEventsSuccessAction => ({
    type: 'backend/GET_EVENTS_SUCCESS',
    events,
  }),
  getEventsError: (error: Error): GetEventsErrorAction => ({
    type: 'backend/GET_EVENTS_ERROR',
    error,
  }),
}

export interface Store {
  backend: BackendState
}

export const selectors = {
  getState: (state: Store): State => state.backend.state,
  getError: (state: Store): Error | undefined => state.backend.error,
  getEvents: (state: Store): Event[] => state.backend.events,
}
