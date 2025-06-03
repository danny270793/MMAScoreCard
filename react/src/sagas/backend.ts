import { put, takeLatest, type ForkEffect } from "redux-saga/effects";
import {
  actions as backendActions,
  type Type as BackendTypes} from '../reducers/backned'

export const sagas: ForkEffect[] = [
  takeLatest<BackendTypes>(
    'backend/GET_EVENTS',
    onGetEventsRequested,
  )
]

function* onGetEventsRequested(): Generator {
  try {
    const events: string[] = yield new Promise((resolve) => {
      setTimeout(() => resolve(['Event 1', 'Event 2', 'Event 3']), 1000);
    });

    yield put(backendActions.getEventsSuccess(events));
  } catch (error) {
    yield put(backendActions.getEventsError(error as Error));
  }
}
