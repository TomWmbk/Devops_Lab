// app.js
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
    res.send('Hello, World!');
});

// Exercice 7 : Endpoint paramétré
app.get('/name/:name', (req, res) => {
    res.send(`Hello, ${req.params.name}!`);
});

// Exercice 9 : Endpoint somme
app.get('/add/:a/:b', (req, res) => {
    const sum = parseInt(req.params.a) + parseInt(req.params.b);
    res.send(sum.toString());
});

module.exports = app;
