import { call, put, takeLatest, type ForkEffect } from 'redux-saga/effects'
import {
  actions as backendActions,
  type Type as BackendTypes,
  type GetEventAction,
  type GetFightAction,
} from '../reducers/backend'
import { Backend } from '../connectors/backend'
import type { Event } from '../connectors/backend/models/event'
import { mapper } from '../connectors/mapper'
import type { Action } from '@reduxjs/toolkit'
import type { Fight } from '../connectors/backend/models/fight'

export const sagas: ForkEffect[] = [
  takeLatest<BackendTypes>('backend/GET_EVENTS', onGetEventsRequested),
  takeLatest<BackendTypes>('backend/GET_EVENT', onGetEventRequested),
  takeLatest<BackendTypes>('backend/GET_FIGHT', onGetFightRequested),
]

function* onGetEventsRequested(): Generator {
  try {
    const events: Event[] = yield call(Backend.getEvents)

    yield put(backendActions.getEventsSuccess(events.map(mapper.toEvent)))
  } catch (error) {
    yield put(backendActions.getEventsError(error as Error))
  }
}

function* onGetEventRequested(action: Action): Generator {
  try {
    const castedAction: GetEventAction = action as GetEventAction

    const event: Event = yield call(Backend.getEvent, castedAction.id)
    const fights: Fight[] = yield call(Backend.getFights, `${event.id}`)

    yield put(
      backendActions.getEventSuccess(
        mapper.toEvent(event),
        fights.map(mapper.toFight),
      ),
    )
  } catch (error) {
    yield put(backendActions.getEventError(error as Error))
  }
}

function* onGetFightRequested(action: Action): Generator {
  try {
    const castedAction: GetFightAction = action as GetFightAction

    const fight: Fight = yield call(Backend.getFight, castedAction.id)

    yield put(
      backendActions.getFightSuccess(
        mapper.toEvent(fight.events),
        mapper.toFight(fight),
      ),
    )
  } catch (error) {
    yield put(backendActions.getFightError(error as Error))
  }
}
