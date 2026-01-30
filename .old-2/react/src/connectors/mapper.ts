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
  toCity(city: BackendCity): City {
    return {
      id: city.id,
      name: city.name,
      country: mapper.toCountry(city.countries),
    }
  },
  toLocation(location: BackendLocation): Location {
    return {
      id: location.id,
      name: location.name,
      city: mapper.toCity(location.cities),
    }
  },
  toEvent(event: BackendEvent): Event {
    return {
      id: event.id,
      name: event.name,
      fight: event.fight,
      date: new Date(event.date),
      link: event.link,
      location: mapper.toLocation(event.locations),
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
  toFighter(fighter: BackendFighter): Fighter {
    return {
      id: fighter.id,
      name: fighter.name,
      nickname: fighter.nickname,
      city: fighter.cities ? mapper.toCity(fighter.cities) : undefined,
      birthday: fighter.birthday ? new Date(fighter.birthday) : undefined,
      died: fighter.died ? new Date(fighter.died) : undefined,
      height: fighter.height,
      weight: fighter.weight,
      link: fighter.link,
    }
  },
  toFight(fight: BackendFight): Fight {
    return {
      id: fight.id,
      winner: fight.winner,
      position: fight.position,
      category: fight.categories
        ? mapper.toCategory(fight.categories)
        : undefined,
      fighterOne: mapper.toFighter(fight.fighterOne),
      fighterTwo: mapper.toFighter(fight.fighterTwo),
      referee: !fight.referees ? undefined : mapper.toReferee(fight.referees),
      mainEvent: fight.mainEvent,
      titleFight: fight.titleFight,
      type: fight.type,
      method: fight.method,
      time: fight.time,
      round: fight.round,
      decision: fight.decision,
      event: mapper.toEvent(fight.events),
    }
  },
}
