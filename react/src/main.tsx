import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { Provider } from 'react-redux'
import { store } from './reducers/index.ts'
import './styles/index.css'
import './i18n'
import Framework7 from 'framework7/lite-bundle'
import Framework7React from 'framework7-react'
import { DarkMode } from './components/dark-mode.tsx'

Framework7.use(Framework7React)

if (window.location.href.startsWith('capacitor://')) {
  if (!window.location.href.startsWith('capacitor://localhost/')) {
    window.location.href = '/'
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Provider store={store}>
      <DarkMode />
    </Provider>
  </StrictMode>,
)
