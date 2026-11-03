const express = require('express');
const app = express();

app.get('/', (_req, res) => {
  res.send('Welcome to OrderFlow v2.3.0');
});

app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'ok',
    version: process.env.RELEASE_VERSION || require('./package.json').version,
  });
});

if (require.main === module) {
  const port = Number(process.env.PORT || 3000);
  app.listen(port, '0.0.0.0', () => {
    console.log(`OrderFlow listening on port ${port}`);
  });
}

module.exports = app;
