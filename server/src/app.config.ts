import config from "@colyseus/tools";
import { monitor } from "@colyseus/monitor";
import { playground } from "@colyseus/playground";
import { TeamLobbyRoom } from "./rooms/TeamLobbyRoom";
import { JWT, Request, auth } from "@colyseus/auth";

/**
 * Import your Room files
 */
import { MyRoom } from "./rooms/MyRoom";
import { LobbyRoom } from "colyseus";
import { CustomLobbyRoom } from "./rooms/CustomLobbyRoom";
import "./config/auth";
import { Migrator } from "kysely";
import { findUserByEmail, insertUser } from "./repository/UserRepository";
import { uWebSocketsTransport } from "@colyseus/uwebsockets-transport";
import express from "express";
//const path = require('node:path');
const serveIndex = require('serve-index');
//import serveIndex from 'serve-index';
import path from 'path';
import bcrypt from 'bcrypt';
import crypto from 'node:crypto';
import { db } from "./db/database";
const cors = require("cors");
export default config({
    initializeTransport: (options) => new uWebSocketsTransport(options),
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

        app.use(cors());

        app.use("/playground", playground);

        app.get("/api/protected", auth.middleware(), (req:Request,res)=>{
            console.log("WTF");
            res.json(req.auth);
        });
        
        app.post("/api/register",async (req:Request,res)=>{
            console.log(req.body);
            //req.
            const { email, password, name } = req.body;
            try {
                console.log('we got: '+email, password, name);
                const hashedPassword = await bcrypt.hash(password, 10);
                console.log("pass hashed: ",hashedPassword);
                const user = await insertUser({user_id: crypto.randomUUID(), email:email, password: hashedPassword, name:name });
                console.log("Can't insert?");
                res.status(201).json({token:"dsaczxcz",user:user});
            } catch (error) {
                console.log(error);
                res.status(400).json({ error: "Email already in use." });
            }
        })
        app.post("/api/login", async (req:Request, res)=>{
            const { email, password } = req.body;
            console.log("want to login?");
            try {
                const user = await findUserByEmail(email);// User.findOne({ where: { email } });

                if (!user) {
                    console.log("user not found");
                    return res.status(401).json({ error: "Invalid email or password." });
                }

                const isPasswordValid = await bcrypt.compare(password, user.password);
                console.log("password: "+password);
                console.log("user password: "+user.password);
                if (!isPasswordValid) {
                    console.log("password is invalid");
                    return res.status(401).json({ error: "Invalid email or password." });
                }

                // Successful login, you can return user data or a session token
                res.json({ token:"fdsfds", user:{ userId: user.user_id, email: user.email }});
            } catch (error) {
                res.status(500).json({ error: "Internal server error" });
            }
        })
        //insertUser({name:"jjj", email:"wtf@mail.com", user_id:"15702B69-884E-45D8-96A2-012A2BF7C848",password:"123"});
        //path
        
        /**
         * Use @colyseus/playground
         * (It is not recommended to expose this route in a production environment)
         */
        
        if (process.env.NODE_ENV !== "production") {
            //app.use("/", playground);
            //app.use('/', serveIndex(path.join(__dirname, ".."), { icons: true, hidden: true }))
            app.use('/', express.static(path.join(__dirname, "..")));
            
        }
        console.log(auth.prefix);

        // Auth + OAuth providers
        app.use(auth.prefix, auth.routes());

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
