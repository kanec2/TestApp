import * as path from 'path'

import { promises as fs } from 'fs'
import {
  Kysely,
  Migrator,
  FileMigrationProvider,
  PostgresDialect,

} from 'kysely'
import { Database } from './db/types';
import { Pool } from 'pg';
//import { config } from './config';

async function migrateToLatest() {
  const db = new Kysely<Database>({
      dialect : new PostgresDialect({pool: new Pool({
        host: 'localhost', //config.database.host,
        database: 'GDB',//config.database.database,
        user: 'admin',//config.database.user,
        password: 'admin',//config.database.password,
        port: 5432//config.port
      })})
  })

  const migrator = new Migrator({
    db,
    provider: new FileMigrationProvider({
      fs,
      path,
      // This needs to be an absolute path.
      migrationFolder: path.join(__dirname, 'migrations'),
    }),
  })

  const { error, results } = await migrator.migrateToLatest()

  results?.forEach((it) => {
    if (it.status === 'Success') {
      console.log(`migration "${it.migrationName}" was executed successfully`)
    } else if (it.status === 'Error') {
      console.error(`failed to execute migration "${it.migrationName}"`)
    }
  })

  if (error) {
    console.error('failed to migrate')
    console.error(error)
    process.exit(1)
  }

  await db.destroy()
}

migrateToLatest()