import express from 'express';
const app = express();

import cors from "cors";
// TODO NOTE: required to allow Svelte to call the backend
app.use(cors({
    origin: 'http://localhost:5173'
}));

import mysql from 'mysql2/promise';

const connection = await mysql.createConnection({
    // TODO NOTE: Get the host string from docker and not localhost
  host: process.env.DATABASE_HOST,
  user: 'user',
  password: 'password',
  database: 'mydb',
  port: 3306
});


app.get("/", (req, res) => {
    res.send("<h1>It works!</h1>");
});

app.get("/data", (req, res) => {
    res.send({ data: "This string comes from the server!" });
});


const PORT = process.env.PORT ?? 8080;
const server = app.listen(PORT, () => console.log('Server is running on port', PORT));