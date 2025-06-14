import express, { Application } from 'express'
import cors from 'cors'
import { router } from './routers'
import { measurer } from './middlewares/measurer'

const app: Application = express()
const port: number = 8000

app.use(measurer())
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(router)

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`)
})
