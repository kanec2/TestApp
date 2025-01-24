import { sql } from 'kysely'
import { db } from '../db/database'

import * as PersonRepository from './UserRepository'

describe('UserRepository', () => {
  before(async () => {
    await db.schema.createTable('users')
      .addColumn('user_id', 'uuid', (cb) => cb.primaryKey().notNull().defaultTo(sql`gen_random_uuid()`))
      .addColumn('name', 'text')
      .addColumn('email', 'text', (cb) => cb.unique())
      .addColumn('password', 'text')
      .addColumn('locale', 'text')
      .addColumn('anonymous', "boolean")
      .addColumn('discord_id', "uuid")
      .execute()
  })
    
  afterEach(async () => {
    await sql`delete from ${sql.table('person')}`.execute(db)
  })
    
  after(async () => {
    await db.schema.dropTable('person').execute()
  })
    
  it('should find a person with a given id', async () => {
    await PersonRepository.findUserById("123");
  })
    
  it('should find all people named Arnold', async () => {
    await PersonRepository.findUsers({name: 'Arnold' })
  })
    
  it('should update gender of a person with a given id', async () => {
    await PersonRepository.updateUser("123", { password: 'woman' })
  })
    
  it('should create a person', async () => {
    await PersonRepository.insertUser({
      name: 'Jennifer',
      password: 'Aniston'
    })
  })
    
  it('should delete a person with a given id', async () => {
    await PersonRepository.deleteUser("123");
  })
})