import { all, type ForkEffect } from 'redux-saga/effects'
import { sagas as backendSagas } from './backend'

const sagasAvailable: ForkEffect[] = [...backendSagas]

export const rootSagas = function* () {
  yield all(sagasAvailable.map((saga) => saga))
}
