const express = require('express');

const app = express();

app.use((req, res, next) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }

  return next();
});

app.get('/', (_req, res) => {
  res.type('text/plain').send('Application is running');
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

module.exports = app;
