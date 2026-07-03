const request = require('supertest');
const app = require('../src/app');

describe('Backend API', () => {
  test('GET / returns the expected plain-text response', async () => {
    const response = await request(app).get('/');

    expect(response.status).toBe(200);
    expect(response.text).toBe('Application is running');
    expect(response.headers['content-type']).toMatch(/text\/plain/);
    expect(response.headers['access-control-allow-origin']).toBe('*');
  });

  test('GET /health returns healthy status JSON', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
    expect(response.headers['access-control-allow-origin']).toBe('*');
  });

  test('GET /api and /api/health support ingress-routed frontend requests', async () => {
    const [rootResponse, healthResponse] = await Promise.all([
      request(app).get('/api'),
      request(app).get('/api/health'),
    ]);

    expect(rootResponse.status).toBe(200);
    expect(rootResponse.text).toBe('Application is running');
    expect(healthResponse.status).toBe(200);
    expect(healthResponse.body).toEqual({ status: 'ok' });
  });
});
