import fs from 'node:fs';

const bundlePath = process.argv[2];

if (!bundlePath) {
  throw new Error('Usage: node scripts/check-contract-invariants.mjs <openapi-bundle.json>');
}

const api = JSON.parse(fs.readFileSync(bundlePath, 'utf8'));
const paths = api.paths;
const schemas = api.components.schemas;

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(api.info.version === '1.3.0', 'Unexpected OpenAPI document version.');
assert(
  !Object.keys(paths).some((path) => path.includes('{token}')),
  'Activation material must not appear in URL paths.',
);

for (const path of [
  '/device-activations/validate',
  '/device-activations/confirm',
  '/device-credentials/exchange',
]) {
  const operation = paths[path]?.post;
  assert(operation?.requestBody, `${path} must accept a request body.`);
  assert(
    !(operation.parameters ?? []).some((parameter) => parameter.name === 'token'),
    `${path} must not accept a token parameter.`,
  );
}

const navigation = schemas.NavigationSummary;
for (const field of [
  'status',
  'source',
  'distanceTraveledMeters',
  'movingDurationSeconds',
  'stoppedDurationSeconds',
  'maximumSpeedMetersPerSecond',
]) {
  assert(navigation.required.includes(field), `Navigation field ${field} must be required.`);
}

for (const status of ['VALID', 'PARTIAL', 'UNAVAILABLE']) {
  assert(
    navigation.oneOf.some((variant) => variant.properties.status.const === status),
    `Navigation status ${status} must have an explicit invariant.`,
  );
}

assert(schemas.TelemetryBatch.properties.schemaVersion.const === 3, 'Telemetry must use schema version 3.');
assert(schemas.DeviceEvent.properties.schemaVersion.const === 2, 'Device events must use schema version 2.');

for (const path of [
  '/device-requests/{requestId}/fulfill',
  '/device-requests/{requestId}/cancel',
]) {
  assert(paths[path]?.post, `Missing DeviceRequest transition ${path}.`);
}

assert(schemas.FulfillDeviceRequest.required.includes('deviceId'), 'Fulfillment must require deviceId.');
assert(schemas.CancelDeviceRequest.required.includes('reason'), 'Cancellation must require a reason.');

for (const status of ['PENDING', 'FULFILLED', 'CANCELLED']) {
  assert(
    schemas.DeviceRequest.oneOf.some((variant) => variant.properties.status.const === status),
    `DeviceRequest status ${status} must have explicit audit invariants.`,
  );
}

for (const [path, pathItem] of Object.entries(paths)) {
  for (const [method, operation] of Object.entries(pathItem)) {
    if (!['get', 'post', 'put', 'patch', 'delete'].includes(method)) {
      continue;
    }

    assert(operation.operationId, `${method.toUpperCase()} ${path} needs an operationId.`);
    assert(operation.summary, `${method.toUpperCase()} ${path} needs a summary.`);
    assert(
      Object.keys(operation.responses ?? {}).some((code) => code.startsWith('4')),
      `${method.toUpperCase()} ${path} needs a 4xx response.`,
    );
  }
}

console.log('Contract invariants: OK');
