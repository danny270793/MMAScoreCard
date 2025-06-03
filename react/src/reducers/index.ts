import { configureStore, type EnhancedStore } from '@reduxjs/toolkit'
import {
  combineReducers,
  type Middleware,
  type Reducer,
  type UnknownAction,
} from 'redux'
import { reducer as backendReducer, type BackendState } from './backned'

export type RootReducer = { backend: BackendState }

export const rootReducer: Reducer<RootReducer> = combineReducers({
  backend: backendReducer,
})

const storeLogger: Middleware = () => (next) => (action) => {
  if (import.meta.env.MODE === 'development') {
    console.log(`Dispatching action: ${(action as UnknownAction).type}`)
  }
  return next(action)
}

export const store: EnhancedStore<RootReducer> = configureStore({
  reducer: rootReducer,
  devTools: import.meta.env.MODE === 'development',
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      thunk: false,
      serializableCheck: false,
    }).concat(storeLogger),
})
