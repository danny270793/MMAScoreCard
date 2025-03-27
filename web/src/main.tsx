import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Home from './pages/home';
import NotFound from './pages/404';
import EventsPage from './pages/events';
import EventPage from './pages/event';
import './css/w3css/index.css'

function renderReactDom() {
  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/index.html" element={<Home />} />
          <Route path="/events" element={<EventsPage />} />
          <Route path="/events/:name" element={<EventPage />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </Router>
    </StrictMode>
  )
}

if (window.cordova) {
  document.addEventListener('deviceready', () => {
    renderReactDom();
  }, false);
} else {
  renderReactDom();
}
