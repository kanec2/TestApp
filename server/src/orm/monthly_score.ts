import { Insertable, Selectable, Updateable } from "kysely";

export interface MonthlyScoreTable{
    name: string;
    user_id: string;
    score: number;
  }

  export type MonthlyScore = Selectable<MonthlyScoreTable>
  export type NewMonthlyScore = Insertable<MonthlyScoreTable>
  export type UpdateMonthlyScore = Updateable<MonthlyScoreTable>