import { Insertable, Selectable, Updateable } from "kysely";

  export interface UserTable {
    name: string;
    email: string;
    password: string;
    discord_id: string;
    locale: string;
    anonymous: boolean;
    user_id:string;
  }

  export type User = Selectable<UserTable>
  export type NewUser = Insertable<UserTable>
  export type UpdateUser = Updateable<UserTable>