import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { Provider } from 'react-redux'
import { store } from './reducers/index.ts'
import './styles/index.css'
import './i18n'
import { DarkMode } from './components/dark-mode.tsx'

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
