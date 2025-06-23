import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { EventsPage } from './pages/events.tsx'
import { EventPage } from './pages/event.tsx'
import { Provider } from 'react-redux'
import { store } from './reducers/index.ts'
import './styles/index.css'
import './styles/framework7.css'
import './i18n'
import Framework7 from 'framework7/lite-bundle'
import Framework7React, { App, View } from 'framework7-react'
import { NotFound } from './pages/not-found.tsx'
import { FightPage } from './pages/fight.tsx'

// eslint-disable-next-line react-hooks/rules-of-hooks
Framework7.use(Framework7React)

if (window.location.href.startsWith('capacitor://')) {
  if (!window.location.href.startsWith('capacitor://localhost/')) {
    window.location.href = '/'
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Provider store={store}>
      <App
        name="MMAScoreCard"
        theme="ios"
        routes={[
          {
            path: '/',
            component: EventsPage,
          },
          {
            path: '/events',
            component: EventsPage,
          },
          {
            path: '/events/:id',
            component: EventPage,
          },
          {
            path: '/fights/:id',
            component: FightPage,
          },
          {
            path: '(.*)',
            component: NotFound,
          },
        ]}
      >
        <View browserHistory />
      </App>
    </Provider>
  </StrictMode>,
)
