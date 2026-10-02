import { readdir, readFile, stat } from 'node:fs/promises'
import assert from 'node:assert/strict'
import { join } from 'node:path'

async function walk(path) {
  return (
    await Promise.all(
      (await readdir(path)).map(async (name) => {
        const file = join(path, name)
        return (await stat(file)).isDirectory() ? walk(file) : [file]
      }),
    )
  ).flat()
}
const files = await walk('dist')
const config = JSON.parse(await readFile('vercel.json', 'utf8'))
assert.equal(config.outputDirectory, 'dist')
assert.equal(config.framework, 'vite')
assert.equal(config.rewrites, undefined, 'No API proxy or catch-all rewrite should be deployed')
assert.equal(config.functions, undefined, 'This deployment has no server functions')
const csp = config.headers[0].headers.find((h) => h.key === 'Content-Security-Policy').value
for (const directive of [
  "connect-src 'none'",
  "form-action 'none'",
  "object-src 'none'",
  "frame-ancestors 'none'",
  "base-uri 'none'",
  "script-src 'self'",
])
  assert.ok(csp.includes(directive), `Missing CSP directive: ${directive}`)
assert.ok(!csp.includes('unsafe-'))
for (const file of files) {
  assert.match(
    file,
    /^dist\/(index\.html|favicon\.svg|third-party-notices\.txt|assets\/[a-zA-Z0-9._-]+\.(js|css|woff2))$/,
    `Unexpected deployed file: ${file}`,
  )
  if (/\.(js|html|css)$/.test(file)) {
    const text = await readFile(file, 'utf8')
    assert.doesNotMatch(
      text,
      /\.ts\.net\b|(?:https?:\/\/)(?:localhost|127\.0\.0\.1|192\.168\.|10\.\d+\.|172\.(?:1[6-9]|2\d|3[01])\.)|BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY|\.sqlite3\b/,
      `Private endpoint or sensitive file reference in ${file}`,
    )
  }
}
assert.ok(files.includes('dist/index.html'))
process.stdout.write(
  `Deployment boundary verified: ${files.length} static files; no backend, legacy source, uploads, databases, or source maps.\n`,
)
