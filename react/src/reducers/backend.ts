import type { UnknownAction } from '@reduxjs/toolkit'
import type { Event } from '../models/event'
import type { Fight } from '../models/fight'
import type { Fighter } from '../models/fighter'

export type Type =
  | 'backend/INIT'
  | 'backend/CLEAR_ERROR'
  | 'backend/GET_EVENTS'
  | 'backend/GET_EVENTS_SUCCESS'
  | 'backend/GET_EVENTS_ERROR'
  | 'backend/GET_EVENT'
  | 'backend/GET_EVENT_SUCCESS'
  | 'backend/GET_EVENT_ERROR'
  | 'backend/GET_FIGHT'
  | 'backend/GET_FIGHT_SUCCESS'
  | 'backend/GET_FIGHT_ERROR'
  | 'backend/GET_FIGHTER'
  | 'backend/GET_FIGHTER_SUCCESS'
  | 'backend/GET_FIGHTER_ERROR'

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

export interface GetFightAction extends Action {
  type: 'backend/GET_FIGHT'
  id: string
}

export interface GetFightSuccessAction extends Action {
  type: 'backend/GET_FIGHT_SUCCESS'
  event: Event
  fight: Fight
}

export interface GetFightErrorAction extends Action {
  type: 'backend/GET_FIGHT_ERROR'
  error: Error
}

export interface GetFighterAction extends Action {
  type: 'backend/GET_FIGHTER'
  id: string
}

export interface GetFighterSuccessAction extends Action {
  type: 'backend/GET_FIGHTER_SUCCESS'
  fighter: Fighter
  fights: Fight[]
}

export interface GetFighterErrorAction extends Action {
  type: 'backend/GET_FIGHTER_ERROR'
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
  | 'getting_fight'
  | 'getting_fight_success'
  | 'getting_fight_error'
  | 'getting_fighter'
  | 'getting_fighter_success'
  | 'getting_fighter_error'

export interface BackendState {
  state: State
  error: Error | undefined
  events: Event[]
  event: Event | undefined
  fights: Fight[]
  fight: Fight | undefined
  fighter: Fighter | undefined
}

export const initialState: BackendState = {
  state: 'initting',
  error: undefined,
  events: [],
  event: undefined,
  fights: [],
  fight: undefined,
  fighter: undefined,
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

    case 'backend/GET_FIGHT':
      return {
        ...state,
        state: 'getting_fight',
        error: undefined,
      }
    case 'backend/GET_FIGHT_SUCCESS':
      return {
        ...state,
        state: 'getting_fight_success',
        event: (action as GetFightSuccessAction).event,
        fight: (action as GetFightSuccessAction).fight,
      }
    case 'backend/GET_FIGHT_ERROR':
      return {
        ...state,
        state: 'getting_fight_error',
        error: (action as GetFightErrorAction).error,
      }

    case 'backend/GET_FIGHTER':
      return {
        ...state,
        state: 'getting_fighter',
        error: undefined,
      }
    case 'backend/GET_FIGHTER_SUCCESS':
      return {
        ...state,
        state: 'getting_fighter_success',
        fighter: (action as GetFighterSuccessAction).fighter,
        fights: (action as GetFighterSuccessAction).fights,
      }
    case 'backend/GET_FIGHTER_ERROR':
      return {
        ...state,
        state: 'getting_fighter_error',
        error: (action as GetFighterErrorAction).error,
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

  getFight: (id: string) => ({
    type: 'backend/GET_FIGHT',
    id,
  }),
  getFightSuccess: (event: Event, fight: Fight): GetFightSuccessAction => ({
    type: 'backend/GET_FIGHT_SUCCESS',
    event,
    fight,
  }),
  getFightError: (error: Error): GetFightErrorAction => ({
    type: 'backend/GET_FIGHT_ERROR',
    error,
  }),

  getFighter: (id: string) => ({
    type: 'backend/GET_FIGHTER',
    id,
  }),
  getFighterSuccess: (
    fighter: Fighter,
    fights: Fight[],
  ): GetFighterSuccessAction => ({
    type: 'backend/GET_FIGHTER_SUCCESS',
    fighter,
    fights,
  }),
  getFighterError: (error: Error): GetFighterErrorAction => ({
    type: 'backend/GET_FIGHTER_ERROR',
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
  getFight: (state: Store): Fight | undefined => state.backend.fight,
  getFighter: (state: Store): Fighter | undefined => state.backend.fighter,
}
