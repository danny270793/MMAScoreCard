import { useNavigate, type NavigateFunction } from 'react-router-dom'

export interface Navigator {
  goBack: () => void
  goToEvent: (id: string) => void
}

export const useNavigator = (): Navigator => {
  const navigate: NavigateFunction = useNavigate()

  return {
    goBack: () => navigate(-1),
    goToEvent: (id: string) => navigate(`/events/${id}`),
  }
}
