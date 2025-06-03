import { call, put, takeLatest, type ForkEffect } from "redux-saga/effects";
import {
  actions as backendActions,
  type Type as BackendTypes} from '../reducers/backend'
import { Backend } from "../connectors/backend";
import type { Event } from "../connectors/backend/models/event";
import { mapper } from "../connectors/mapper";
import type { Location } from "../connectors/backend/models/location";
import type { City } from "../connectors/backend/models/city";
import type { Country } from "../models/country";

export const sagas: ForkEffect[] = [
  takeLatest<BackendTypes>(
    'backend/GET_EVENTS',
    onGetEventsRequested,
  )
]

function* onGetEventsRequested(): Generator {
  try {
    const events: Event[] = yield call(Backend.getEvents)
    const locations: Location[] = yield call(Backend.getLocations)
    const cities: City[] = yield call(Backend.getCities)
    const countries: Country[] = yield call(Backend.getCountries)

    yield put(backendActions.getEventsSuccess(events.map((event: Event) => mapper.toEvent(event, locations, cities, countries))));
  } catch (error) {
    yield put(backendActions.getEventsError(error as Error));
  }
}
