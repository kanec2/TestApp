// schema.ts
import {
    Insertable,
    Selectable,
    Updateable,
  } from 'kysely'
  
export interface Database {
    user: UserTable
    monthly_score: MonthlyScoreTable
}

export interface UserTable {
    name: string,
    email: string,
    password: string,
    discord_id: string,
    locale: string,
    anonymous: boolean,
    user_id:string
}

export type User = Selectable<UserTable>
export type NewUser = Insertable<UserTable>
export type UserUpdate = Updateable<UserTable>

export interface MonthlyScoreTable {
    name: string,
    user_id: string,
    score: number
}
  
export type MonthlyScore = Selectable<MonthlyScoreTable>
export type NewMonthlyScore = Insertable<MonthlyScoreTable>
export type MonthlyScoreUpdate = Updateable<MonthlyScoreTable>