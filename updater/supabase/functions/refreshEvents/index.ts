import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';
import { Logger } from './libraries/logger.ts'
import { Sherdog } from './libraries/sherdog/index.ts'
import { Event } from "./libraries/sherdog/models/event.ts";
import { DoneFight, Fight } from "./libraries/sherdog/models/fight.ts";
import { MemoryCache } from "./libraries/cache/memory-cache.ts"
import { Cache } from "./libraries/cache/index.ts";

const logger: Logger = new Logger('/index.ts')

const weights: Record<string, number> = {
    Strawweight: 115,
    Flyweight: 125,
    Bantamweight: 135,
    Featherweight: 145,
    Lightweight: 155,
    Welterweight: 170,
    Middleweight: 185,
    'Light Heavyweight': 205,
    Heavyweight: 225,
}

function sendResponse(data: any|Error) {
  return new Response(JSON.stringify((data instanceof Error) ? {
      message: data?.message ?? data
    } : {
    ...data
  }), {
    headers: {
      'Content-Type': 'application/json'
    },
    status: (data instanceof Error) ? 500 : 200
  });
}

async function getTable(supabase, table: string) {
  const { data, error } = await supabase.from(table).select('*');
  if (error) {
    throw error;
  }
  return data
}

async function insertInTable(supabase, table: string, rows: unknown[]) {
  const { data, error } = await supabase
    .from(table)
    .insert(rows)

  if (error) {
    throw error;
  }

  return await getTable(supabase, table)
}

Deno.serve(async (req)=>{
  try {
    logger.debug('login to supabase')
    const url: string = Deno.env.get('SUPABASE_URL') ?? ''
    const key: string = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    const supabase = createClient(url, key, {
      global: {
        headers: {
          Authorization: req.headers.get('Authorization')
        }
      }
    });
    
    logger.debug('getting sherdog events')
    const cache: Cache = new MemoryCache()
    const sherdog: Sherdog = new Sherdog()
    sherdog.setCache(cache)
    const sherdogEvents: Event[] = await sherdog.getEventsFromPage(1)

    logger.debug('deleting not completed events')
    const { error } = await supabase
      .from('events')
      .delete()
      .eq('status', 'uppcoming')
    if(error) {
      throw error
    }

    logger.debug('add new countries')
    const supabaseCountries: any[] = await getTable(supabase, 'countries')
    const countriesToAdd: unknown[] = []
    for(const sherdogEvent of sherdogEvents) {
      const countryExists: boolean = supabaseCountries.filter(country => sherdogEvent.country === country.name).length > 0
      const countryAlreadyAdded: boolean = countriesToAdd.filter((country: any) => sherdogEvent.country === country.name).length > 0
      if(!countryExists && !countryAlreadyAdded) {
        countriesToAdd.push({name: sherdogEvent.country})
      }
    }
    if(countriesToAdd.length > 0) {
      logger.debug(`${countriesToAdd.length} countries added`)
      supabaseCountries.length = 0
      supabaseCountries.push(...await insertInTable(supabase, 'countries', countriesToAdd))
    }

    logger.debug('add new cities')
    const supabaseCities: any[] = await getTable(supabase, 'cities')
    const citiesToAdd: unknown[] = []
    for(const sherdogEvent of sherdogEvents) {
      const country: any = supabaseCountries.filter(country => sherdogEvent.country === country.name)[0]
      const cityExists: boolean = supabaseCities.filter(city => sherdogEvent.city === city.name).length > 0
      const cityAlreadyAdded: boolean = citiesToAdd.filter((city: any) => sherdogEvent.city === city.name).length > 0
      if(!cityExists && !cityAlreadyAdded) {
        citiesToAdd.push({name: sherdogEvent.city, countryId: country.id})
      }
    }
    if(citiesToAdd.length > 0) {
      logger.debug(`${citiesToAdd.length} cities added`)
      supabaseCities.length = 0
      supabaseCities.push(...await insertInTable(supabase, 'cities', citiesToAdd)) 
    }

    logger.debug('add new locations')
    const supabaseLocations: any[] = await getTable(supabase, 'locations')
    const locationsToAdd: unknown[] = []
    for(const sherdogEvent of sherdogEvents) {
      const city: any = supabaseCities.filter(city => sherdogEvent.city === city.name)[0]
      const locationExists: boolean = supabaseLocations.filter(location => sherdogEvent.location === location.name).length > 0
      const locationAlreadyAdded: boolean = locationsToAdd.filter((location: any) => sherdogEvent.location === location.name).length > 0
      if(!locationExists && !locationAlreadyAdded) {
        locationsToAdd.push({name: sherdogEvent.location, cityId: city.id})
      }
    }
    if(locationsToAdd.length > 0) {
      logger.debug(`${locationsToAdd.length} locations added`)
      supabaseLocations.length = 0
      supabaseLocations.push(...await insertInTable(supabase, 'locations', locationsToAdd))
    }

    logger.debug('add new events')
    const supabaseEvents: any[] = await getTable(supabase, 'events')
    const eventsToAdd: unknown[] = []
    for(const sherdogEvent of sherdogEvents) {
      const location: any = supabaseLocations.filter(location => sherdogEvent.location === location.name)[0]
      const eventExists: boolean = supabaseEvents.filter(event => sherdogEvent.name === event.name).length > 0
      const eventAlreadyAdded: boolean = eventsToAdd.filter((event: any) => sherdogEvent.name === event.name).length > 0
      if(!eventExists && !eventAlreadyAdded) {
        eventsToAdd.push({
          name: sherdogEvent.name,
          fight: sherdogEvent.fight,
          date: sherdogEvent.date,
          link: sherdogEvent.link,
          status: sherdogEvent.state,
          locationId: location.id
        })
      }
    }
    if(eventsToAdd.length > 0) {
      logger.debug(`${eventsToAdd.length} events added`)
      supabaseEvents.length = 0
      supabaseEvents.push(...await insertInTable(supabase, 'events', eventsToAdd))
    }

    const addedEvents = supabaseEvents.filter(supabaseEvent => eventsToAdd.filter((eventToAdd: any) => eventToAdd.name === supabaseEvent.name).length > 0)
    logger.debug(`addedEvents.length=${addedEvents.length}`)

    logger.debug('add new categories')
    const supabaseCategories: any[] = await getTable(supabase, 'categories')
    const categoriesToAdd: unknown[] = []
    for(const sherdogEvent of addedEvents) {
      const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent)
      
      for (const fight of fights) {
        if (!fight.category) {
          continue
        }

        const categoryExists: boolean = supabaseCategories.filter(category =>
          fight.category!.name === category.name &&
          weights[fight.category!.name] === category.weight
        ).length > 0
        const categoryAlreadyAdded: boolean = categoriesToAdd.filter((category: any) =>
          fight.category!.name === category.name &&
          weights[fight.category!.name] === category.weight
        ).length > 0
        if(!categoryExists && !categoryAlreadyAdded) {
          categoriesToAdd.push({name: fight.category.name, weight: weights[fight.category.name]})
        }
      }
    }
    if(categoriesToAdd.length > 0) {
      logger.debug(`${categoriesToAdd.length} categories added`)
      supabaseCategories.length = 0
      supabaseCategories.push(...await insertInTable(supabase, 'categories', categoriesToAdd))
    }

    logger.debug('add new referees')
    const supabaseReferees: any[] = await getTable(supabase, 'referees')
    const refereesToAdd: unknown[] = []
    for(const sherdogEvent of addedEvents) {
      const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent)
      
      for (const fight of fights) {
        if (fight.type === 'pending') {
          continue
        }

        const refereeExists: boolean = supabaseReferees.filter(referee => fight.referee === referee.name).length > 0
        const refereeAlreadyAdded: boolean = refereesToAdd.filter((referee: any) => fight.referee === referee.name).length > 0
        if(!refereeExists && !refereeAlreadyAdded) {
          refereesToAdd.push({name: fight.referee})
        }
      }
    }
    if(refereesToAdd.length > 0) {
      logger.debug(`${refereesToAdd.length} referees added`)
      supabaseReferees.length = 0
      supabaseReferees.push(...await insertInTable(supabase, 'referees', refereesToAdd))
    }

    return sendResponse(supabaseEvents)
  } catch (err) {
    return sendResponse(err)
  }
});
