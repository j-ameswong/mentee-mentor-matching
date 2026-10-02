import { expect, test, type Page } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

async function navigate(page: Page, label: string) {
  const menu = page.getByRole('button', { name: 'Open navigation', exact: true })
  if (await menu.isVisible()) await menu.click()
  await page.getByRole('navigation').getByRole('button', { name: label, exact: true }).click()
}
async function introduce(
  page: Page,
  alias = 'campus.coder',
  message = 'Hi! I would love some help with first-year coding projects and finding my feet.',
) {
  await page.goto('/#/mentee/discover')
  await page.getByRole('button', { name: `View ${alias}'s profile` }).click()
  await page.getByRole('textbox', { name: 'Introduction' }).fill(message)
  await page.getByRole('button', { name: 'Send request' }).click()
  await expect(page.getByRole('dialog')).toHaveCount(0)
}

test('one introduction travels through acceptance, privacy, withdrawal, and admin review', async ({
  page,
}) => {
  const errors: string[] = []
  const requests: string[] = []
  page.on('pageerror', (e) => errors.push(e.message))
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(msg.text())
  })
  page.on('request', (r) => requests.push(r.url()))
  await introduce(page)
  await expect(page.getByText('Request sent · awaiting a reply')).toBeVisible()
  await navigate(page, 'My connections')
  await expect(page.getByRole('heading', { name: 'campus.coder', exact: true })).toBeVisible()
  await expect(page.getByText('Maya Chen', { exact: true })).toHaveCount(0)
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('mentor')
  await navigate(page, 'My connections')
  const request = page
    .locator('article')
    .filter({ has: page.getByRole('heading', { name: 'cs.student', exact: true }) })
  await request.getByRole('button', { name: 'Accept request' }).click()
  await expect(page.getByRole('heading', { name: 'Ava Walker', exact: true })).toBeVisible()
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('mentee')
  await navigate(page, 'My connections')
  await page.getByRole('button', { name: 'View full profile' }).click()
  await expect(page.getByRole('dialog')).toContainText('Maya Chen')
  await expect(page.getByRole('dialog')).toContainText('maya@example.org')
  await page.keyboard.press('Escape')
  await navigate(page, 'Support desk')
  await page.getByLabel('Request type').selectOption('withdrawal')
  await page.getByLabel('Your connection', { exact: true }).selectOption('maya')
  await page
    .getByLabel('Request details')
    .fill('My timetable has changed. I would like to end this fictional connection.')
  await page.getByRole('button', { name: 'Send demo request' }).click()
  await expect(page.locator('.ticket-card')).toContainText('withdrawal')
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('admin')
  await navigate(page, 'Support desk')
  await page.getByRole('button', { name: 'Approve withdrawal' }).click()
  await page.getByLabel('Include resolved').check()
  await expect(page.getByText('Withdrawal approved', { exact: true })).toBeVisible()
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('mentee')
  await navigate(page, 'My connections')
  await expect(page.getByRole('heading', { name: 'campus.coder', exact: true })).toBeVisible()
  await expect(page.getByRole('button', { name: 'View full profile' })).toHaveCount(0)
  await navigate(page, 'Inbox')
  await expect(page.getByRole('heading', { name: 'Support request updated' })).toBeVisible()
  await page.getByRole('button', { name: 'Mark all as read' }).click()
  await page.getByRole('button', { name: 'Unread (0)', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'No unread notifications' })).toBeVisible()
  expect(errors).toEqual([])
  expect(requests.every((url) => url.startsWith('http://127.0.0.1:4173/'))).toBe(true)
})

test('guided tour completes all perspectives and restores earlier exploration', async ({
  page,
}) => {
  await introduce(page, 'engineering.mentor')
  await navigate(page, 'Overview')
  await page
    .getByRole('main')
    .getByRole('button', { name: 'Start guided tour', exact: true })
    .click()
  const guide = page.getByRole('complementary', { name: 'Guided tour' })
  await expect(guide).toContainText('1 of 8')
  await guide.getByRole('button', { name: 'Continue', exact: true }).click()
  await expect(guide).toContainText('2 of 8')
  await page.getByRole('button', { name: "View campus.coder's profile" }).click()
  await page.getByRole('textbox', { name: 'Introduction' }).fill('Hello from the guided tour.')
  await page.getByRole('button', { name: 'Send request' }).click()
  await expect(guide).toContainText('Step complete.')
  await guide.getByRole('button', { name: 'Continue', exact: true }).click()
  await expect(guide).toContainText('3 of 8')
  await guide.getByRole('button', { name: 'Show me & continue' }).click()
  await expect(guide).toContainText('4 of 8')
  await expect(page.getByRole('heading', { name: 'Maya Chen', exact: true })).toBeVisible()
  await guide.getByRole('button', { name: 'Continue', exact: true }).click()
  await expect(guide).toContainText('5 of 8')
  await guide.getByRole('button', { name: 'Continue', exact: true }).click()
  await expect(guide).toContainText('6 of 8')
  await guide.getByRole('button', { name: 'Show me & continue' }).click()
  await expect(guide).toContainText('7 of 8')
  await guide.getByRole('button', { name: 'Show me & continue' }).click()
  await expect(guide).toContainText('8 of 8')
  await guide.getByRole('button', { name: 'Finish tour' }).click()
  await expect(guide).toHaveCount(0)
  await navigate(page, 'My connections')
  await expect(page.getByRole('heading', { name: 'engineering.mentor', exact: true })).toBeVisible()
  await expect(page.getByRole('heading', { name: 'Maya Chen', exact: true })).toHaveCount(0)
  await page.reload()
  await expect(page.getByRole('heading', { name: 'engineering.mentor', exact: true })).toBeVisible()
})

test('filters, profile editing, reload, and reset work without exposing markup', async ({
  page,
}) => {
  const payload = '<img src=x onerror=alert(1)> A fictional introduction.'
  await page.goto('/#/mentee/discover')
  await page.getByRole('textbox', { name: 'Search mentors' }).fill('nonexistent-interest')
  await expect(page.getByRole('heading', { name: 'No mentors found' })).toBeVisible()
  await page.getByRole('button', { name: 'Clear filters' }).click()
  await page.getByRole('button', { name: 'Coding', exact: true }).click()
  await expect(page.locator('.mentor-card')).toHaveCount(2)
  await navigate(page, 'My profile')
  await page.getByRole('textbox', { name: 'Introduction' }).fill(payload)
  await page.getByRole('button', { name: 'Save profile' }).click()
  await page.reload()
  await expect(page.getByRole('textbox', { name: 'Introduction' })).toHaveValue(payload)
  await page.getByRole('button', { name: 'Reset', exact: true }).click()
  await page.getByRole('button', { name: 'Reset demo', exact: true }).click()
  await navigate(page, 'My profile')
  await expect(page.getByRole('textbox', { name: 'Introduction' })).not.toHaveValue(payload)
  await introduce(page, 'campus.coder', payload)
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('mentor')
  await navigate(page, 'My connections')
  await expect(page.locator('.introduction').filter({ hasText: payload })).toBeVisible()
  await expect(page.locator('img[src="x"]')).toHaveCount(0)
})

test('admin approvals, flags, waitlist, and semester completion affect the shared scenario', async ({
  page,
}) => {
  await page.goto('/#/admin/approvals')
  await page.getByRole('button', { name: 'Approve Samir' }).click()
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('mentee')
  await navigate(page, 'Find a mentor')
  await expect(page.getByRole('heading', { name: 'business.year3' })).toBeVisible()
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('mentor')
  await navigate(page, 'My connections')
  await page.getByRole('button', { name: 'Offer a place' }).click()
  await expect(page.getByRole('heading', { name: 'Theo James', exact: true })).toBeVisible()
  await page.getByRole('button', { name: 'Set availability' }).click()
  await page.getByLabel('Number of mentees').selectOption('2')
  await page.getByRole('button', { name: 'Save availability' }).click()
  await expect(page.getByRole('button', { name: 'Accept request' })).toBeDisabled()
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('admin')
  await navigate(page, 'Accounts')
  const maya = page.getByRole('row').filter({ hasText: 'Maya Chen' })
  await maya.getByRole('button', { name: 'Flag for review' }).click()
  await expect(maya).toContainText('Flagged')
  await maya.getByRole('button', { name: 'Clear flag' }).click()
  await page.getByRole('button', { name: 'Complete demo semester' }).click()
  await page.getByRole('button', { name: 'Complete semester', exact: true }).click()
  await page.getByRole('combobox', { name: 'Demo role' }).selectOption('mentee')
  await navigate(page, 'Find a mentor')
  await expect(page.getByRole('heading', { name: 'Semester completed' })).toBeVisible()
})

test('all main pages have no serious accessibility issues, runtime errors, or mobile overflow', async ({
  page,
}) => {
  const errors: string[] = []
  page.on('pageerror', (e) => errors.push(e.message))
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(msg.text())
  })
  for (const route of [
    'mentee/overview',
    'mentee/discover',
    'mentee/matches',
    'mentee/profile',
    'mentee/notifications',
    'mentee/support',
    'mentor/matches',
    'admin/approvals',
    'admin/community',
    'admin/support',
    'mentee/about',
  ]) {
    await page.goto(`/#/${route}`)
    await expect(page.getByRole('main').getByRole('heading', { level: 1 })).toBeVisible()
    const issues = (
      await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21aa']).analyze()
    ).violations
    expect(
      issues.map((v) => ({ id: v.id, impact: v.impact, nodes: v.nodes.map((n) => n.target) })),
      route,
    ).toEqual([])
    expect(
      await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth),
      route,
    ).toBe(true)
  }
  expect(errors).toEqual([])
})

test('dialogs, guided tour, and navigation are accessible by keyboard', async ({ page }) => {
  await page.goto('/#/mentee/discover')
  const trigger = page.getByRole('button', { name: "View campus.coder's profile" })
  await trigger.focus()
  await page.keyboard.press('Enter')
  await expect(page.getByRole('dialog')).toBeVisible()
  await expect(page.getByRole('textbox', { name: 'Introduction' })).toBeFocused()
  const issues = (
    await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21aa']).analyze()
  ).violations
  expect(issues.map((v) => ({ id: v.id, nodes: v.nodes.map((n) => n.target) }))).toEqual([])
  await page.keyboard.press('Escape')
  await expect(page.getByRole('dialog')).toHaveCount(0)
  await expect(trigger).toBeFocused()
  await navigate(page, 'Overview')
  await page
    .getByRole('main')
    .getByRole('button', { name: 'Start guided tour', exact: true })
    .click()
  const tourIssues = (
    await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21aa']).analyze()
  ).violations
  expect(tourIssues.map((v) => ({ id: v.id, nodes: v.nodes.map((n) => n.target) }))).toEqual([])
  await page.getByRole('button', { name: 'Exit guided tour' }).click()
  await expect(page.getByRole('complementary', { name: 'Guided tour' })).toHaveCount(0)
})

test('malformed storage and disallowed role routes recover; browser tabs remain isolated', async ({
  page,
  context,
}) => {
  await page.goto('/')
  await page.evaluate(() => sessionStorage.setItem('uniconnect-demo-v1', '{broken'))
  await page.goto('/#/mentee/community')
  await expect(
    page.getByRole('heading', { name: 'Find a mentor. Manage your requests.' }),
  ).toBeVisible()
  await introduce(page)
  const other = await context.newPage()
  await other.goto('/#/mentee/matches')
  await expect(other.getByRole('heading', { name: 'No connections yet' })).toBeVisible()
  await other.close()
  await page.reload()
  await expect(page.getByText('Request sent · awaiting a reply')).toBeVisible()
})

test('storage-denied browsers can still explore and reset', async ({ page }) => {
  await page.addInitScript(() => {
    Storage.prototype.getItem = () => {
      throw new Error('Storage disabled')
    }
    Storage.prototype.setItem = () => {
      throw new Error('Storage disabled')
    }
    Storage.prototype.removeItem = () => {
      throw new Error('Storage disabled')
    }
  })
  await introduce(page)
  await expect(
    page.getByRole('status').filter({ hasText: 'Browser storage is unavailable' }),
  ).toBeVisible()
  await page.getByRole('button', { name: 'Reset', exact: true }).click()
  await page.getByRole('button', { name: 'Reset demo', exact: true }).click()
  await expect(
    page.getByRole('heading', { name: 'Find a mentor. Manage your requests.' }),
  ).toBeVisible()
})

test('production security headers and deployment boundaries fail closed', async ({
  request,
  page,
}) => {
  const response = await request.get('/')
  expect(response.status()).toBe(200)
  expect(response.headers()['content-security-policy']).toContain("connect-src 'none'")
  expect(response.headers()['content-security-policy']).not.toContain('unsafe-')
  expect(response.headers()['x-content-type-options']).toBe('nosniff')
  expect(response.headers()['x-frame-options']).toBe('DENY')
  for (const path of [
    '/app.rb',
    '/db/db_test.sqlite3',
    '/.env',
    '/.git/config',
    '/public/images/user/970546678',
    '/api',
    '/signup/admin',
    '/src/App.tsx',
  ])
    expect((await request.get(path)).status(), path).toBe(404)
  expect((await request.post('/signup/admin', { data: { role: 'admin' } })).status()).toBe(405)
  await page.goto('/')
  const blocked = await page.evaluate(async () => {
    try {
      await fetch('/api')
      return false
    } catch {
      return true
    }
  })
  expect(blocked).toBe(true)
})
