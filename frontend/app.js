// In local Docker Compose, BACKEND_URL points to http://localhost:8080.
// In Kubernetes, BACKEND_URL can be set to /api so the browser stays on one public hostname
// and ingress routes API traffic internally to the backend service.
const defaultBackendUrl = 'http://localhost:8080';
const apiBaseUrl = (window.APP_CONFIG && window.APP_CONFIG.BACKEND_URL) || defaultBackendUrl;

const elements = {
  backendUrl: document.getElementById('backend-url'),
  statusBanner: document.getElementById('status-banner'),
  rootEndpointLabel: document.getElementById('root-endpoint-label'),
  rootResponse: document.getElementById('root-response'),
  healthEndpointLabel: document.getElementById('health-endpoint-label'),
  healthResponse: document.getElementById('health-response'),
};

const setBanner = (message, variant) => {
  elements.statusBanner.textContent = message;
  elements.statusBanner.className = `status-banner status-banner--${variant}`;
};

const setLoadingState = () => {
  elements.backendUrl.textContent = `Backend: ${apiBaseUrl}`;
  elements.rootEndpointLabel.textContent = `Fetching ${apiBaseUrl}/`;
  elements.healthEndpointLabel.textContent = `Fetching ${apiBaseUrl}/health`;
  elements.rootResponse.textContent = 'Loading…';
  elements.healthResponse.textContent = 'Loading…';
  setBanner('Loading backend responses…', 'loading');
};

const formatJson = (value) => JSON.stringify(value, null, 2);

const fetchText = async (url) => {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Request to ${url} failed with status ${response.status}`);
  }
  return response.text();
};

const fetchJson = async (url) => {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Request to ${url} failed with status ${response.status}`);
  }
  return response.json();
};

const setErrorState = (error) => {
  const message = `Unable to reach backend at ${apiBaseUrl}. ${error.message}`;
  setBanner(message, 'error');
  elements.rootResponse.textContent = message;
  elements.healthResponse.textContent = message;
};

const loadBackendStatus = async () => {
  setLoadingState();

  try {
    const [rootResponse, healthResponse] = await Promise.all([
      fetchText(`${apiBaseUrl}/`),
      fetchJson(`${apiBaseUrl}/health`),
    ]);

    elements.rootResponse.textContent = rootResponse;
    elements.healthResponse.textContent = formatJson(healthResponse);
    setBanner('Backend responses loaded successfully.', 'success');
  } catch (error) {
    setErrorState(error);
  }
};

loadBackendStatus();
