const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello, World!');
});

app.get('/name/:name', (req, res) => {
    res.send(`Hello, ${req.params.name}!`);
});

module.exports = app;
