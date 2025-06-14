import type { Location } from './location'

export interface Event {
  id: number
  name: string
  fight?: string
  date: Date
  link: string
  location: Location
  status: string
}

export const EmptyEvent: Event = {
  date: new Date(),
  id: 1,
  link: '',
  name: 'ufc 350',
  status: 'uppcomming',
  fight: 'tom aspinall vs. jones jones',
  location: {
    id: 1,
    name: 'Madison Square Garden',
    city: {
      id: 1,
      name: 'New York',
      country: { id: 1, name: 'USA' },
    },
  },
}
