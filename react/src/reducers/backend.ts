import type { UnknownAction } from '@reduxjs/toolkit'
import type { Event } from '../models/event'
import type { Fight } from '../models/fight'

export type Type =
  | 'backend/INIT'
  | 'backend/CLEAR_ERROR'
  | 'backend/GET_EVENTS'
  | 'backend/GET_EVENTS_SUCCESS'
  | 'backend/GET_EVENTS_ERROR'
  | 'backend/GET_EVENT'
  | 'backend/GET_EVENT_SUCCESS'
  | 'backend/GET_EVENT_ERROR'

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

export interface GetEventAction extends Action {
  type: 'backend/GET_EVENT'
  id: string
}

export interface GetEventSuccessAction extends Action {
  type: 'backend/GET_EVENT_SUCCESS'
  event: Event
  fights: Fight[]
}

export interface GetEventErrorAction extends Action {
  type: 'backend/GET_EVENT_ERROR'
  error: Error
}

export type State =
  | 'initting'
  | 'getting_events'
  | 'getting_events_success'
  | 'getting_events_error'
  | 'getting_event'
  | 'getting_event_success'
  | 'getting_event_error'

export interface BackendState {
  state: State
  error: Error | undefined
  events: Event[]
  event: Event | undefined
  fights: Fight[]
}

export const initialState: BackendState = {
  state: 'initting',
  error: undefined,
  events: [],
  event: undefined,
  fights: [],
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

    case 'backend/GET_EVENT':
      return {
        ...state,
        state: 'getting_event',
        error: undefined,
      }
    case 'backend/GET_EVENT_SUCCESS':
      return {
        ...state,
        state: 'getting_event_success',
        event: (action as GetEventSuccessAction).event,
        fights: (action as GetEventSuccessAction).fights,
      }
    case 'backend/GET_EVENT_ERROR':
      return {
        ...state,
        state: 'getting_event_error',
        error: (action as GetEventErrorAction).error,
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
  getEvent: (id: string) => ({
    type: 'backend/GET_EVENT',
    id,
  }),
  getEventSuccess: (event: Event, fights: Fight[]): GetEventSuccessAction => ({
    type: 'backend/GET_EVENT_SUCCESS',
    event,
    fights,
  }),
  getEventError: (error: Error): GetEventErrorAction => ({
    type: 'backend/GET_EVENT_ERROR',
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
  getEvent: (state: Store): Event | undefined => state.backend.event,
  getFights: (state: Store): Fight[] => state.backend.fights,
}
