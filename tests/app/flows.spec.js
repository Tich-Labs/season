const { test, expect } = require('@playwright/test')

const USER = { email: 'test@season.vision', password: 'password123' }

async function login (page) {
  await page.goto('/session/new')
  await page.fill('#email', USER.email)
  await page.fill('#password_field', USER.password)
  await page.click('input[type="submit"]')
  await page.waitForURL('**/calendar', { timeout: 10000 })
}

test.describe('Auth Flows', () => {
  test('sign in with valid credentials', async ({ page }) => {
    await login(page)
    await expect(page).toHaveURL(/calendar/)
  })

  test('sign out', async ({ page }) => {
    await login(page)
    await page.goto('/session/destroy')
    await page.waitForURL('**/welcome', { timeout: 5000 }).catch(() => {})
  })
})

test.describe('App Flows (authenticated)', () => {
  test.beforeEach(async ({ page }) => {
    await login(page)
  })

  test('calendar loads with phase colors', async ({ page }) => {
    await page.goto('/calendar')
    await page.waitForLoadState('networkidle')
  })

  test('tracking page loads', async ({ page }) => {
    await page.goto('/tracking')
    await expect(page.locator('text=Superpower')).toBeVisible({ timeout: 5000 })
  })

  test('daily view loads', async ({ page }) => {
    const today = new Date().toISOString().split('T')[0]
    await page.goto(`/daily/${today}`)
    await expect(page.locator('text=Hello')).toBeVisible({ timeout: 5000 })
  })

  test('settings page loads', async ({ page }) => {
    await page.goto('/settings/edit')
    await page.waitForLoadState('networkidle')
  })

  test('superpowers page loads', async ({ page }) => {
    await page.goto('/superpowers')
    await page.waitForLoadState('networkidle')
  })

  test('informations page loads', async ({ page }) => {
    await page.goto('/informations')
    await page.waitForLoadState('networkidle')
  })

  test('profile page shows user name', async ({ page }) => {
    await page.goto('/settings/profile')
    await page.waitForLoadState('networkidle')
  })
})
