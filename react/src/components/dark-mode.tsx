import { App, View } from 'framework7-react'
import { useEffect, useState, type FC } from 'react'
import { EventsPage } from '../pages/events'
import { EventPage } from '../pages/event'
import { FightPage } from '../pages/fight'
import { FighterPage } from '../pages/fighter'
import { NotFound } from '../pages/not-found'

export const DarkMode: FC = () => {
  const [darkMode, setDarkMode] = useState(
    () => window.matchMedia('(prefers-color-scheme: dark)').matches,
  )

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handler = (event: MediaQueryListEvent) => setDarkMode(event.matches)

    mediaQuery.addEventListener('change', handler)

    return () => mediaQuery.removeEventListener('change', handler)
  }, [])

  return (
    <App
      name="MMAScoreCard"
      theme="ios"
      darkMode={darkMode}
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
          path: '/fighters/:id',
          component: FighterPage,
        },
        {
          path: '(.*)',
          component: NotFound,
        },
      ]}
    >
      <View browserHistory />
    </App>
  )
}
