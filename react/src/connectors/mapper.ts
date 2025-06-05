import type { Event } from '../models/event'
import type { Event as BackendEvent } from './backend/models/event'
import type { Location as BackendLocation } from './backend/models/location'
import type { Location } from '../models/location'
import type { City as BackendCity } from './backend/models/city'
import type { City } from '../models/city'
import type { Country as BackendCountry } from './backend/models/country'
import type { Country } from '../models/country'

export const mapper = {
  toCountry(country: BackendCountry): Country {
    return {
      id: country.id,
      name: country.name,
    }
  },
  toCity(city: BackendCity, countries: BackendCountry[]): City {
    return {
      id: city.id,
      name: city.name,
      country: mapper.toCountry(
        countries.find((country) => country.id === city.countryId)!,
      ),
    }
  },
  toLocation(
    location: BackendLocation,
    cities: BackendCity[],
    countries: BackendCountry[],
  ): Location {
    return {
      id: location.id,
      name: location.name,
      city: mapper.toCity(
        cities.find((city) => city.id === location.cityId)!,
        countries,
      ),
    }
  },
  toEvent(
    event: BackendEvent,
    locations: BackendLocation[],
    cities: BackendCity[],
    countries: BackendCountry[],
  ): Event {
    return {
      id: event.id,
      name: event.name,
      fight: event.fight,
      date: new Date(event.date),
      link: event.link,
      location: mapper.toLocation(
        locations.find((location) => location.id === event.locationId)!,
        cities,
        countries,
      ),
      status: event.status,
    }
  },
}
