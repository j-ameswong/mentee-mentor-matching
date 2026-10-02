// Local-only production preview using the exact security headers shipped to Vercel.
import { createServer } from 'node:http'
import { readFile, stat } from 'node:fs/promises'
import { resolve, extname, sep } from 'node:path'

const root = resolve('dist')
const config = JSON.parse(await readFile('vercel.json', 'utf8'))
const mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8',
}
const server = createServer(async (request, response) => {
  for (const { key, value } of config.headers[0].headers) response.setHeader(key, value)
  response.setHeader('Cache-Control', 'no-store')
  if (!['GET', 'HEAD'].includes(request.method)) {
    response.writeHead(405, { Allow: 'GET, HEAD' })
    response.end()
    return
  }
  try {
    const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname)
    const file = resolve(root, `.${pathname === '/' ? '/index.html' : pathname}`)
    if (!file.startsWith(root + sep) || !mime[extname(file)] || !(await stat(file)).isFile())
      throw new Error('Not found')
    response.setHeader('Content-Type', mime[extname(file)])
    response.end(request.method === 'HEAD' ? undefined : await readFile(file))
  } catch {
    response.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' })
    response.end('Not found')
  }
})
server.listen(4173, '127.0.0.1', () =>
  process.stdout.write('Production preview: http://127.0.0.1:4173\n'),
)
