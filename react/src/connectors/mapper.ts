import type { Event } from '../models/event'
import type { Event as BackendEvent } from './backend/models/event'
import type { Location as BackendLocation } from './backend/models/location'
import type { Location } from '../models/location'
import type { City as BackendCity } from './backend/models/city'
import type { City } from '../models/city'
import type { Country as BackendCountry } from './backend/models/country'
import type { Country } from '../models/country'
import type { Fight as BackendFight } from './backend/models/fight'
import type { Fight } from '../models/fight'
import type { Category as BackendCategory } from './backend/models/category'
import type { Category } from '../models/category'
import type { Referee } from '../models/referee'
import type { Referee as BackendReferee } from './backend/models/referee'
import type { Fighter } from '../models/fighter'
import type { Fighter as BackendFighter } from './backend/models/fighter'

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
  toCategory(category: BackendCategory): Category {
    return {
      id: category.id,
      name: category.name,
      weight: category.weight,
    }
  },
  toReferee(referee: BackendReferee): Referee {
    return {
      id: referee.id,
      name: referee.name,
    }
  },
  toFighter(
    fighter: BackendFighter,
    cities: BackendCity[],
    countries: BackendCountry[],
  ): Fighter {
    return {
      id: fighter.id,
      name: fighter.name,
      nickname: fighter.nickname,
      city: mapper.toCity(
        cities.find((city) => city.id === fighter.cityId)!,
        countries,
      ),
      birthday: fighter.birthday ? new Date(fighter.birthday) : undefined,
      died: fighter.died ? new Date(fighter.died) : undefined,
      height: fighter.height,
      weight: fighter.weight,
      link: fighter.link,
    }
  },
  toFight(
    fight: BackendFight,
    categories: BackendCategory[],
    cities: BackendCity[],
    countries: BackendCountry[],
    locations: BackendLocation[],
    referees: BackendReferee[],
    fighters: BackendFighter[],
    events: BackendEvent[],
  ): Fight {
    const referee: BackendReferee | undefined = referees.find(
      (referee: BackendReferee) => referee.id === fight.referee,
    )
    return {
      id: fight.id,
      position: fight.position,
      category: mapper.toCategory(
        categories.find(
          (category: BackendCategory) => category.id === fight.categoryId,
        )!,
      ),
      fighterOne: mapper.toFighter(
        fighters.find(
          (fighter: BackendFighter) => fighter.id === fight.fighterOne,
        )!,
        cities,
        countries,
      ),
      fighterTwo: mapper.toFighter(
        fighters.find(
          (fighter: BackendFighter) => fighter.id === fight.fighterTwo,
        )!,
        cities,
        countries,
      ),
      referee: !referee
        ? undefined
        : mapper.toReferee(
            referees.find(
              (referee: BackendReferee) => referee.id === fight.referee,
            )!,
          ),
      mainEvent: Boolean(fight.mainEvent),
      titleFight: Boolean(fight.titleFight),
      type: fight.type,
      method: fight.method,
      time: fight.time,
      round: fight.round,
      decision: fight.decision,
      event: mapper.toEvent(
        events.find((event: BackendEvent) => event.id === fight.eventId)!,
        locations,
        cities,
        countries,
      ),
    }
  },
}
