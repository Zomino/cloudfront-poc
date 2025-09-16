export const handler = async () => ({
  statusCode: 200,
  statusDescription: '200 OK',
  isBase64Encoded: false,
  headers: { 'content-type': 'text/plain; charset=utf-8' },
  body: 'こんにちは、世界'
});
