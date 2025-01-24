import { Kysely, sql } from 'kysely'

export async function up(db: Kysely<any>): Promise<void> {
  await db.schema.createTable('user')
    .addColumn('user_id', 'uuid', (cb) => cb.primaryKey().notNull().defaultTo(sql`gen_random_uuid()`))
    .addColumn('name', 'text')
    .addColumn('email', 'text', (cb) => cb.unique())
    .addColumn('password', 'text')
    .addColumn('locale', 'text')
    .addColumn('anonymous', "boolean")
    .addColumn('discord_id', "uuid")
  .execute()

  await db.schema.createTable("monthly_scores")
    .addColumn("id", "uuid", (col) => col.primaryKey())
    .addColumn("user_id", "uuid")
    .addColumn("score", "integer")
    .execute();
  /*
  await db.schema
    .createTable('pet')
    .addColumn('id', 'integer', (col) => col.primaryKey())
    .addColumn('name', 'text', (col) => col.notNull().unique())
    .addColumn('owner_id', 'integer', (col) =>
      col.references('person.id').onDelete('cascade').notNull(),
    )
    .addColumn('species', 'text', (col) => col.notNull())
    .execute()

  await db.schema
    .createIndex('pet_owner_id_index')
    .on('pet')
    .column('owner_id')
    .execute()*/
}

export async function down(db: Kysely<any>): Promise<void> {
  await db.schema.dropTable('user').execute()
}