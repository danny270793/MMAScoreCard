import { call, put, takeLatest, type ForkEffect } from "redux-saga/effects";
import {
  actions as backendActions,
  type Type as BackendTypes} from '../reducers/backned'
import { Backend } from "../connectors/backend";
import type { Event } from "../connectors/backend/models/event";

export const sagas: ForkEffect[] = [
  takeLatest<BackendTypes>(
    'backend/GET_EVENTS',
    onGetEventsRequested,
  )
]

function* onGetEventsRequested(): Generator {
  try {
    const events: Event[] = yield call(Backend.getEvents)

    yield put(backendActions.getEventsSuccess(events));
  } catch (error) {
    yield put(backendActions.getEventsError(error as Error));
  }
}
