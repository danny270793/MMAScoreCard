import { NextFunction, Request, Response } from "express";

export const measurer = () => {
    return (request: Request, response: Response, next: NextFunction) => {
        const start: number = Date.now()
      
        response.on('finish', () => {
            const end: number = Date.now()
            const duration: number = end - start
            console.log(`${new Date()} ${request.method} ${request.originalUrl} - ${duration}ms`)
        })
      
        next()
    }
}
