import { call, put, takeLatest, type ForkEffect } from 'redux-saga/effects'
import {
  actions as backendActions,
  type Type as BackendTypes,
  type GetEventAction,
} from '../reducers/backend'
import { Backend } from '../connectors/backend'
import type { Event } from '../connectors/backend/models/event'
import { mapper } from '../connectors/mapper'
import type { Location } from '../connectors/backend/models/location'
import type { City } from '../connectors/backend/models/city'
import type { Country } from '../models/country'
import type { Action } from '@reduxjs/toolkit'
import type { Fight } from '../connectors/backend/models/fight'
import type { Category } from '../connectors/backend/models/category'
import type { Referee } from '../connectors/backend/models/referee'
import type { Fighter } from '../connectors/backend/models/fighter'

export const sagas: ForkEffect[] = [
  takeLatest<BackendTypes>('backend/GET_EVENTS', onGetEventsRequested),
  takeLatest<BackendTypes>('backend/GET_EVENT', onGetEventRequested),
]

function* onGetEventsRequested(): Generator {
  try {
    const events: Event[] = yield call(Backend.getEvents)
    events.sort((a: Event, b: Event) => {
      const dateA = new Date(a.date)
      const dateB = new Date(b.date)
      return dateB.getTime() - dateA.getTime()
    })

    const locations: Location[] = yield call(Backend.getLocations)
    const cities: City[] = yield call(Backend.getCities)
    const countries: Country[] = yield call(Backend.getCountries)

    yield put(
      backendActions.getEventsSuccess(
        events.map((event: Event) =>
          mapper.toEvent(event, locations, cities, countries),
        ),
      ),
    )
  } catch (error) {
    yield put(backendActions.getEventsError(error as Error))
  }
}

function* onGetEventRequested(action: Action): Generator {
  try {
    const castedAction: GetEventAction = action as GetEventAction

    const events: Event[] = yield call(Backend.getEvents)
    const event: Event = events.filter(
      (event: Event) => `${event.id}` === castedAction.id,
    )[0]

    const categories: Category[] = yield call(Backend.getCategories)
    const cities: City[] = yield call(Backend.getCities)
    const countries: Country[] = yield call(Backend.getCountries)
    const locations: Location[] = yield call(Backend.getLocations)
    const referees: Referee[] = yield call(Backend.getReferees)
    const fighters: Fighter[] = yield call(Backend.getFighters)
    const fights: Fight[] = yield call(Backend.getFights, `${event.id}`)

    fights.sort((a: Fight, b: Fight) => {
      return b.position - a.position
    })

    yield put(
      backendActions.getEventSuccess(
        mapper.toEvent(event, locations, cities, countries),
        fights.map((fight: Fight) =>
          mapper.toFight(
            fight,
            categories,
            cities,
            countries,
            locations,
            referees,
            fighters,
            events,
          ),
        ),
      ),
    )
  } catch (error) {
    yield put(backendActions.getEventError(error as Error))
  }
}
