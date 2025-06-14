import { Request, Response, Router } from "express";
import { Event, Fight, Sherdog } from "../libraries/sherdog";
import { Cache } from "../libraries/cache";
import { FileCache } from "../libraries/cache/file-cache";
import { error } from "node:console";

export const router: Router = Router()

const sherdog: Sherdog = new Sherdog()
const cache: Cache = new FileCache('.cached.json')
sherdog.setCache(cache)

router.get('/events/:name', async (request: Request, response: Response<Fight[]>) => {
    try {
        const events: Event[] = await sherdog.getEvents()
        const filteredEvents: Event[] = events.filter((event: Event) => event.name === request.params.name)
        if(filteredEvents.length !== 1) {
            response.status(404).json()
        }
        const event: Event = filteredEvents[0]
        response.json(await sherdog.getFights(event))
    } catch(error) {
        console.error(error)
        response.status(500).json()
    }
})

router.get('/events', async (request: Request, response: Response<Event[]>) => {
    try {
        response.json(await sherdog.getEvents())
    } catch(error) {
        console.error(error)
        response.status(500).json()
    }
})
