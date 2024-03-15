import express from 'express';
const app = express();

app.get("/", (req, res) => {
    res.send("<h1>It works!</h1>");
});

const PORT = process.env.PORT ?? 8080;
const server = app.listen(PORT, () => console.log('Server is running on port', PORT));