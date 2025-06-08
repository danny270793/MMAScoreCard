import Events from './assets/events.json'
import Categories from './assets/categories.json'
import type { Category } from './models/category'
import Countries from './assets/countries.json'
import Cities from './assets/cities.json'
import type { Country } from './models/country'
import type { City } from './models/city'
import Fighters from './assets/fighters.json'
import type { Fighter } from './models/fighter'
import Fights from './assets/fights.json'
import type { Fight } from './models/fight'
import Locations from './assets/locations.json'
import type { Location } from './models/location'
import Referees from './assets/referees.json'
import type { Referee } from './models/referee'
import type { Event } from './models/event'

export class Backend {
  static async getCategories(): Promise<Category[]> {
    return Categories.map<Category>((category: unknown) => category as Category)
  }
  static async getCities(): Promise<City[]> {
    return Cities.map<City>((city: unknown) => city as City)
  }
  static async getCountries(): Promise<Country[]> {
    return Countries.map<Country>((country: unknown) => country as Country)
  }
  static async getEvents(): Promise<Event[]> {
    return Events.map<Event>((event: unknown) => event as Event)
  }
  static async getFighters(): Promise<Fighter[]> {
    return Fighters.map<Fighter>((fighter: unknown) => fighter as Fighter)
  }
  static async getFights(id: string): Promise<Fight[]> {
    return Fights.map<Fight>((fight: unknown) => fight as Fight).filter(
      (fight: Fight) => `${fight.eventId}` === id,
    )
  }
  static async getLocations(): Promise<Location[]> {
    return Locations.map<Location>((location: unknown) => location as Location)
  }
  static async getReferees(): Promise<Referee[]> {
    return Referees.map<Referee>((referee: unknown) => referee as Referee)
  }
}
