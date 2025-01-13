import { ORM } from './orm/orm' // this is the Database interface we defined earlier

import { Kysely, SqliteDialect } from 'kysely'
import SQLite from 'better-sqlite3';

const dialect = new SqliteDialect({
  database: new SQLite(':memory:'),
})

// Database interface is passed to Kysely's constructor, and from now on, Kysely 
// knows your database structure.
// Dialect is passed to Kysely's constructor, and from now on, Kysely knows how 
// to communicate with your database.
export const db = new Kysely<ORM>({
  dialect,
})