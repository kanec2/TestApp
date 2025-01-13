import { db } from "../database"
import { NewUser, UpdateUser, User } from "../orm/user"

export async function findUserById(id: string) {
  return await db.selectFrom('user')
    .where('user_id', '=', id)
    .selectAll()
    .executeTakeFirst()
}
export async function findUserByEmail(email: string) {
  return await db.selectFrom('user')
    .where('email', '=', email)
    .selectAll()
    .executeTakeFirst()
}
export async function findUser(criteria: Partial<User>) {
  let query = db.selectFrom('user')

  if (criteria.user_id) {
    query = query.where('user_id', '=', criteria.user_id) // Kysely is immutable, you must re-assign!
  }

  if (criteria.email) {
    query = query.where('email', '=', criteria.email)
  }

  if (criteria.name) {
    query = query.where('name', '=', criteria.name)
  }
  return await query.selectAll().execute()
}

export async function updateUser(id: string, updateWith: UpdateUser) {
  await db.updateTable('user').set(updateWith).where('user_id', '=', id).execute()
}

export async function createPerson(person: NewUser) {
  return await db.insertInto('user')
    .values(person)
    .returningAll()
    .executeTakeFirstOrThrow()
}

export async function deletePerson(id: string) {
  return await db.deleteFrom('user').where('user_id', '=', id)
    .returningAll()
    .executeTakeFirst()
}