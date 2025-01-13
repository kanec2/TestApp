import config from "@colyseus/tools";
import { monitor } from "@colyseus/monitor";
import { playground } from "@colyseus/playground";
import { TeamLobbyRoom } from "./rooms/TeamLobbyRoom";
/**
 * Import your Room files
 */
import { MyRoom } from "./rooms/MyRoom";
import { LobbyRoom } from "colyseus";
import { CustomLobbyRoom } from "./rooms/CustomLobbyRoom";

export default config({

    initializeGameServer: (gameServer) => {
        /**
         * Define your room handlers:
         */
        
        // Expose the "lobby" room.
        gameServer.define("lobby", CustomLobbyRoom,{
            gameMode:"1x1"
        });
        // Expose your game room with realtime listing enabled.
        gameServer.define('my_room', MyRoom);//.enableRealtimeListing();
        gameServer.define("team_lobby", TeamLobbyRoom,{
            gameMode:"2x2"
        });

        gameServer.simulateLatency(200);
    },

    initializeExpress: (app) => {
        /**
         * Bind your custom express routes here:
         * Read more: https://expressjs.com/en/starter/basic-routing.html
         */
        app.get("/hello_world", (req, res) => {
            res.send("It's time to kick ass and chew bubblegum!");
        });

        /**
         * Use @colyseus/playground
         * (It is not recommended to expose this route in a production environment)
         */
        if (process.env.NODE_ENV !== "production") {
            app.use("/", playground);
        }

        /**
         * Use @colyseus/monitor
         * It is recommended to protect this route with a password
         * Read more: https://docs.colyseus.io/tools/monitor/#restrict-access-to-the-panel-using-a-password
         */
        app.use("/colyseus", monitor());
    },


    beforeListen: () => {
        /**
         * Before before gameServer.listen() is called.
         */
    }
});
