const express = require('express');
const app = express();
const releaseVersion = process.env.RELEASE_VERSION || process.env.npm_package_version || require('./package.json').version;

app.get('/', (req, res) => {
  res.send('Welcome to the OrderFlow API');
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', version: releaseVersion });
});

if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`OrderFlow ${releaseVersion} listening on port ${port}`);
  });
}

module.exports = app;
