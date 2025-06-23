import type { Category } from './models/category'
import type { Country } from './models/country'
import type { City } from './models/city'
import type { Fighter } from './models/fighter'
import type { Fight } from './models/fight'
import type { Location } from './models/location'
import type { Referee } from './models/referee'
import type { Event } from './models/event'
import { createClient, SupabaseClient } from '@supabase/supabase-js'
import { LocalStorageCache } from './cache/local-storage'
import type { Cache } from './cache'

const supabaseUrl: string = import.meta.env.VITE_SUPABASE_URL
const supabaseKey: string = import.meta.env.VITE_SUPABASE_ANON_KEY
const supabase: SupabaseClient = createClient(supabaseUrl, supabaseKey)

export class Backend {
  static cache: Cache | undefined =
    import.meta.env.MODE === 'development' ? new LocalStorageCache() : undefined

  static async getEvents(): Promise<Event[]> {
    const key: string = 'events'
    if (Backend.cache && (await Backend.cache.has(key))) {
      const events: string = await Backend.cache.get(key)
      return JSON.parse(events)
    }

    const { data, error } = await supabase
      .from('events')
      .select(
        'id,name,fight,date,link,status,locations(id,name,cities(id,name,countries(id,name)))',
      )
      .order('date', { ascending: false })
    if (error) {
      throw error
    }
    if (Backend.cache) {
      await Backend.cache.set(key, data)
    }
    return data.map((event: unknown) => event as Event)
  }

  static async getEvent(id: string): Promise<Event> {
    const key: string = `event_${id}`
    if (Backend.cache && (await Backend.cache.has(key))) {
      const event: string = await Backend.cache.get(key)
      return JSON.parse(event)[0]
    }

    const { data, error } = await supabase
      .from('events')
      .select(
        'id,name,fight,date,link,status,locations(id,name,cities(id,name,countries(id,name)))',
      )
      .eq('id', id)
    if (error) {
      throw error
    }
    if (Backend.cache) {
      await Backend.cache.set(key, data)
    }
    return data.map((event: unknown) => event as Event)[0]
  }

  static async getFighter(id: string): Promise<Fighter> {
    const key: string = `fighter_${id}`
    if (Backend.cache && (await Backend.cache.has(key))) {
      const fights: string = await Backend.cache.get(key)
      return JSON.parse(fights)
    }

    const { data, error } = await supabase
      .from('fighters')
      .select(
        `id,name,nickname,cities(id,name,countries(id,name)),birthday,died,height,weight,link`,
      )
      .eq('id', id)
    if (error) {
      throw error
    }
    if (Backend.cache) {
      await Backend.cache.set(key, data)
    }
    return data.map((fighter: unknown) => fighter as Fighter)[0]
  }

  static async getFights(eventId: string): Promise<Fight[]> {
    const key: string = `fights_${eventId}`
    if (Backend.cache && (await Backend.cache.has(key))) {
      const fights: string = await Backend.cache.get(key)
      return JSON.parse(fights)
    }

    const { data, error } = await supabase
      .from('fights_with_figthers')
      .select(
        `id,position,
        categories(id,name,weight),
        referees(id,name),
        winner,
        fightertwoid,fightertwoname,fightertwonickname,fightertwobirthday,fightertwodied,fightertwoheight,fightertwoweight,fightertwolink,
        fighteroneid,fighteronename,fighteronenickname,fighteronebirthday,fighteronedied,fighteroneheight,fighteroneweight,fighteronelink,
        mainEvent,titleFight,type,method,time,round,decision,
        events(id,name,fight,date,link,status,locations(id,name,cities(id,name,countries(id,name))))`,
      )
      .eq('eventId', eventId)
      .order('position', { ascending: false })
    if (error) {
      throw error
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const parsedData: Fight[] = data.map<Fight>((fight: any) => ({
      id: fight.id,
      position: fight.position,
      winner: fight.winner,
      categories:
        fight.categories &&
        ({
          id: fight.categories.id,
          name: fight.categories.name,
          weight: fight.categories.weight,
        } as Category),
      fighterOne: {
        id: fight.fighteroneid,
        name: fight.fighteronename,
        nickname: fight.fighteronenickname,
        cities: {
          id: fight.fighteronecityid,
          name: fight.fighteronecityname,
          countries: {
            id: fight.fighteronecountryid,
            name: fight.fighteronecountryname,
          } as Country,
        } as City,
        birthday: fight.fighteronebirthday
          ? new Date(fight.fighteronebirthday)
          : undefined,
        died: fight.fighteronedied ? new Date(fight.fighteronedied) : undefined,
        height: fight.fighteroneheight,
        weight: fight.fighteroneweight,
        link: fight.fighteronelink,
      } as Fighter,
      fighterTwo: {
        id: fight.fightertwoid,
        name: fight.fightertwoname,
        nickname: fight.fightertwonickname,
        cities: {
          id: fight.fightertwocityid,
          name: fight.fightertwocityname,
          countries: {
            id: fight.fightertwocountryid,
            name: fight.fightertwocountryname,
          } as Country,
        } as City,
        birthday: fight.fightertwobirthday
          ? new Date(fight.fightertwobirthday)
          : undefined,
        died: fight.fightertwodied ? new Date(fight.fightertwodied) : undefined,
        height: fight.fightertwoheight,
        weight: fight.fightertwoweight,
        link: fight.fightertwolink,
      } as Fighter,
      referees: fight.referees
        ? ({
            id: fight.referees.id,
            name: fight.referees.name,
          } as Referee)
        : undefined,
      mainEvent: fight.mainEvent,
      titleFight: fight.titleFight,
      type: fight.type,
      method: fight.method,
      time: fight.time,
      round: fight.round,
      decision: fight.decision,
      events: {
        id: fight.events.id,
        name: fight.events.name,
        fight: fight.events.fight,
        date: fight.events.date,
        link: fight.events.link,
        locations: {
          id: fight.events.locations.id,
          name: fight.events.locations.name,
          cities: {
            id: fight.events.locations.cities.id,
            name: fight.events.locations.cities.name,
            countries: {
              id: fight.events.locations.cities.countries.id,
              name: fight.events.locations.cities.countries.name,
            } as Country,
          } as City,
        } as Location,
        status: fight.events.status,
      } as Event,
    }))

    if (Backend.cache) {
      await Backend.cache.set(key, parsedData)
    }
    return parsedData
  }

  static async getFight(id: string): Promise<Fight> {
    const key: string = `fight_${id}`
    if (Backend.cache && (await Backend.cache.has(key))) {
      const fight: string = await Backend.cache.get(key)
      return JSON.parse(fight)
    }

    const { data, error } = await supabase
      .from('fights_with_figthers')
      .select(
        `id,position,
        categories(id,name,weight),
        referees(id,name),
        winner,
        fightertwoid,fightertwoname,fightertwonickname,fightertwobirthday,fightertwodied,fightertwoheight,fightertwoweight,fightertwolink,
        fighteroneid,fighteronename,fighteronenickname,fighteronebirthday,fighteronedied,fighteroneheight,fighteroneweight,fighteronelink,
        mainEvent,titleFight,type,method,time,round,decision,
        events(id,name,fight,date,link,status,locations(id,name,cities(id,name,countries(id,name))))`,
      )
      .eq('id', id)
    if (error) {
      throw error
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const parsedData: Fight = data.map<Fight>((fight: any) => {
      return {
        id: fight.id,
        winner: fight.winner,
        position: fight.position,
        categories:
          fight.categories &&
          ({
            id: fight.categories.id,
            name: fight.categories.name,
            weight: fight.categories.weight,
          } as Category),
        fighterOne: {
          id: fight.fighteroneid,
          name: fight.fighteronename,
          nickname: fight.fighteronenickname,
          cities: {
            id: fight.fighteronecityid,
            name: fight.fighteronecityname,
            countries: {
              id: fight.fighteronecountryid,
              name: fight.fighteronecountryname,
            } as Country,
          } as City,
          birthday: fight.fighteronebirthday
            ? new Date(fight.fighteronebirthday)
            : undefined,
          died: fight.fighteronedied
            ? new Date(fight.fighteronedied)
            : undefined,
          height: fight.fighteroneheight,
          weight: fight.fighteroneweight,
          link: fight.fighteronelink,
        } as Fighter,
        fighterTwo: {
          id: fight.fightertwoid,
          name: fight.fightertwoname,
          nickname: fight.fightertwonickname,
          cities: {
            id: fight.fightertwocityid,
            name: fight.fightertwocityname,
            countries: {
              id: fight.fightertwocountryid,
              name: fight.fightertwocountryname,
            } as Country,
          } as City,
          birthday: fight.fightertwobirthday
            ? new Date(fight.fightertwobirthday)
            : undefined,
          died: fight.fightertwodied
            ? new Date(fight.fightertwodied)
            : undefined,
          height: fight.fightertwoheight,
          weight: fight.fightertwoweight,
          link: fight.fightertwolink,
        } as Fighter,
        referees: fight.referees
          ? ({
              id: fight.referees.id,
              name: fight.referees.name,
            } as Referee)
          : undefined,
        mainEvent: fight.mainEvent,
        titleFight: fight.titleFight,
        type: fight.type,
        method: fight.method,
        time: fight.time,
        round: fight.round,
        decision: fight.decision,
        events: {
          id: fight.events.id,
          name: fight.events.name,
          fight: fight.events.fight,
          date: fight.events.date,
          link: fight.events.link,
          locations: {
            id: fight.events.locations.id,
            name: fight.events.locations.name,
            cities: {
              id: fight.events.locations.cities.id,
              name: fight.events.locations.cities.name,
              countries: {
                id: fight.events.locations.cities.countries.id,
                name: fight.events.locations.cities.countries.name,
              } as Country,
            } as City,
          } as Location,
          status: fight.events.status,
        } as Event,
      }
    })[0]

    if (Backend.cache) {
      await Backend.cache.set(key, parsedData)
    }
    return parsedData
  }
}
