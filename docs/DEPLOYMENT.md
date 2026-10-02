# Deployment decision

Use **Vercel for the entire static portfolio**. A backend and Tailscale Funnel are unnecessary for the intended visitor experience.

The Ruby version assumed a long-running Sinatra process, mutable SQLite files, uploaded images, and real sessions. Keeping those online just for a portfolio adds operational work and an avoidable route into the homelab. The showcase instead implements the matching rules in a typed browser model, with a separate fictional scenario for each visitor. There is no multi-user persistence, authentication, or real communication to host.

```text
Visitor ── HTTPS ── Vercel static files
                    index.html + JS + CSS + fonts + favicon
   └─ fictional state in this browser tab

Homelab: no connection, no new service, no Funnel change
```

[Vercel supports Vite builds](https://vercel.com/docs/frameworks/frontend/vite) and [Node.js 24 for builds](https://vercel.com/changelog/node-js-24-lts-is-now-generally-available-for-builds-and-functions). [Tailscale Funnel exposes a selected service to the public internet](https://tailscale.com/docs/features/tailscale-funnel); it is a transport, not a substitute for application security. The findings in [SECURITY.md](SECURITY.md) rule out exposing the historical server as it stands.

## Settings already in the repository

| Setting                                  | Value           |
| ---------------------------------------- | --------------- |
| Vercel framework                         | Vite            |
| Root directory                           | Repository root |
| Node                                     | 24.x            |
| Install command                          | `npm ci`        |
| Build command                            | `npm run build` |
| Output directory                         | `dist`          |
| Required environment variables / secrets | None            |
| Server functions / API proxy / rewrites  | None            |
| Runtime database / homelab service       | None            |

`vercel.json` provides the build settings and response headers. `.vercelignore` uses [Vercel’s documented allowlist pattern](https://vercel.com/docs/deployments/vercel-ignore) to upload just the required build inputs. The legacy app, databases, uploads, local settings, documentation, and test results are excluded. Vite’s `publicDir` is the new `assets/`, which prevents legacy `public/` from being copied to `dist/`.

Navigation uses fragments such as `/#/mentor/matches`. Consequently, no catch-all rewrite is required: unknown server paths can return 404 rather than falling back to the app. Do not add an API route, proxy, catch-all rewrite, remote font, or analytics script without reviewing the security boundary.

## Local readiness check

```sh
nvm use
npm ci
npx playwright install chromium
npm run check
npm run audit:dependencies
npm run preview
```

The preview at `http://127.0.0.1:4173` sends the same configured security headers as Vercel. Vite’s development server needs a WebSocket for hot reload, so production CSP checks deliberately run against this preview.

## Verified deployment — 2 October 2026

Vercel CLI 62.2.0 was already authenticated as `j-ameswong`, matching the repository owner. A new `uniconnect-portfolio` project was created in the existing personal scope `j-ameswongs-projects`. No login input, application secrets, paid features, Git connection, or homelab changes were needed. Other Vercel projects were left untouched.

**[Open the protected preview](https://uniconnect-portfolio-jdpnpjx29-j-ameswongs-projects.vercel.app)** using the owner's Vercel sign-in. Its [deployment dashboard](https://vercel.com/j-ameswongs-projects/uniconnect-portfolio/Ch65NxhBvDimo52UsnPkDgDbdGNz) reports `READY` in the preview environment. There is no retained production deployment. This preview includes the revised interface copy: functional headings, direct instructions and factual notifications.

Verified against Vercel itself:

- CLI upload dry run: **28 approved build input files**; no historical backend, databases, uploaded images, local environment files, or legacy scripts. The manifest is saved in [deployment-inputs.json](deployment-inputs.json).
- Remote clean install, TypeScript build, and output audit succeeded; **seven static output files, zero functions**. The hosted HTML, JavaScript, and CSS match the local build byte for byte.
- All configured security headers are present on the root, assets, and tested missing paths. Optional Vercel toolbar injection was disabled for this project; the strict CSP remains intact.
- `/app.rb`, `/.env`, `/db/db_test.sqlite3`, `/public/images/user/970546678`, `/api`, and `/signup/admin` all return **404** after passing deployment protection.
- The full eight-step tour completes and restores previous changes on desktop and mobile Chromium, with no runtime errors, external requests, or horizontal overflow.
- Unauthenticated preview access redirects to Vercel sign-in. The temporary automation bypass used for verification was revoked afterward.

Sanitized edge and browser results are recorded in [hosted-verification.json](hosted-verification.json).

**First-deployment behavior:** Vercel automatically promoted the first deployment despite an explicit preview target. That static deployment briefly received the production alias. A separate protected preview was then created, and the first deployment was removed. Both its unique URL and `https://uniconnect-portfolio.vercel.app` now return 404. The retained preview contains no backend or homelab connection.

## Future deployments

The local `.vercel/` project link is ignored by Git. On another machine, authenticate and link the existing project. Do not paste a Vercel token into chat or put it in the repository.

```sh
npx vercel@62.2.0 login
npx vercel@62.2.0 whoami
npx vercel@62.2.0 link --project uniconnect-portfolio --scope j-ameswongs-projects
```

After changing application code, run the local checks and create another preview:

```sh
npm run check
npm run audit:dependencies
npx vercel@62.2.0 deploy --target preview --scope j-ameswongs-projects
```

Validate each changed preview before publishing:

1. Open the site in a clean browser and complete the tour on desktop and a narrow screen.
2. Inspect actual response headers for `/`, a JavaScript asset, and an unknown path. Confirm the CSP, `nosniff`, frame restrictions, and referrer policy are present.
3. Request `/app.rb`, `/.env`, `/db/db_test.sqlite3`, `/public/images/user/970546678`, `/api`, and `/signup/admin`; they must not expose files or handlers.
4. Confirm browser network requests stay on the deployment origin and contain only static resources. Confirm no Vercel Functions or proxy routes were created.
5. Check the project's deployment protection settings so the intended portfolio audience can open the final production URL. Keep the optional Vercel toolbar disabled rather than relaxing the app policy.

When ready to make the portfolio public, deliberately create a production deployment and check it while signed out:

```sh
npx vercel@62.2.0 deploy --prod --scope j-ameswongs-projects
```

Git-based automatic deployment can be connected later. The CLI deployment did not require a commit, push, or change to the remote repository.

## If a live backend is ever desired

Treat that as a separate project, not a setting to turn on. The historical application needs repaired authorization and authentication, upgraded dependencies, CSRF tokens, session hardening, upload isolation, request limits, and a fresh audit. An isolated container or VM with no homelab mounts, Docker socket, secrets, tailnet administration access, or lateral network access would be a minimum architectural starting point. Funnel would expose only that restricted service, with deliberate proxy and host validation. Existing Funnel services should not be reconfigured to accommodate this portfolio.
