const assert = require('assert');
const app = require('./server');

console.log('Running OrderFlow Release Validation Tests...');

// Helper to test Express route handlers directly without requiring external sockets
function testEndpoint(method, url) {
  return new Promise((resolve, reject) => {
    let statusCode = 200;
    let responseBody = null;

    const req = {
      method,
      url,
      headers: {}
    };

    const res = {
      status(code) {
        statusCode = code;
        return this;
      },
      setHeader() {
        return this;
      },
      send(data) {
        responseBody = data;
        resolve({ statusCode, body: responseBody });
        return this;
      },
      json(data) {
        responseBody = data;
        resolve({ statusCode, body: responseBody });
        return this;
      }
    };

    app.handle(req, res, (err) => {
      if (err) reject(err);
    });
  });
}

async function runTests() {
  try {
    // Test 1: GET /
    const homeRes = await testEndpoint('GET', '/');
    assert.strictEqual(homeRes.statusCode, 200, 'GET / should return HTTP 200');
    assert.strictEqual(homeRes.body, 'Welcome to the Release Readiness Lab API', 'GET / body mismatch');
    console.log('PASS: GET / endpoint verified');

    // Test 2: GET /health
    const healthRes = await testEndpoint('GET', '/health');
    assert.strictEqual(healthRes.statusCode, 200, 'GET /health should return HTTP 200');
    assert.strictEqual(healthRes.body.status, 'ok', 'GET /health status should be "ok"');
    assert.strictEqual(healthRes.body.version, '2.3.0', 'GET /health version should be "2.3.0"');
    console.log('PASS: GET /health endpoint verified (status: ok, version: 2.3.0)');

    console.log('Validation passed: All application tests passed successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Validation failed with error:', err);
    process.exit(1);
  }
}

runTests();
