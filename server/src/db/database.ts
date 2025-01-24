import { Kysely, PostgresDialect } from 'kysely'
import { Database } from './types';
import {Pool} from 'pg'
import { config } from '../config';
const dialect = new PostgresDialect({
  pool: new Pool({
    database: config.database.database,
    host: config.database.host,
    user: config.database.user,
    password: config.database.password,
    port: config.port,
    max: 10
  })
})

// Database interface is passed to Kysely's constructor, and from now on, Kysely 
// knows your database structure.
// Dialect is passed to Kysely's constructor, and from now on, Kysely knows how 
// to communicate with your database.
export const db = new Kysely<Database>({
  dialect,
})