import { fromFile, Parser } from '@asyncapi/parser';

const documentPath = process.argv[2];

if (!documentPath) {
  throw new Error('Usage: node scripts/validate-asyncapi.mjs <asyncapi.yaml>');
}

const parser = new Parser();
const { document, diagnostics } = await fromFile(parser, documentPath).parse();

for (const diagnostic of diagnostics) {
  const location = diagnostic.range?.start
    ? `${diagnostic.range.start.line + 1}:${diagnostic.range.start.character + 1}`
    : 'unknown location';
  const severity = diagnostic.severity === 0 ? 'error' : 'warning';
  console.log(`[${severity}] ${location} ${diagnostic.message}`);
}

if (!document || diagnostics.some((diagnostic) => diagnostic.severity === 0)) {
  throw new Error('AsyncAPI validation failed.');
}

console.log('AsyncAPI: valid');
