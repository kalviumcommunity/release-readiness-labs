const express = require('express');
const app = express();
const port = process.env.PORT;

app.get('/', (req, res) => {
  res.send('Welcome to the Release Readiness Lab API');
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', version: process.env.npm_package_version });
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
