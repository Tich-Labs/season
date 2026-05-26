const { test, expect } = require('@playwright/test')

// Smoke tests — verify pages load and UI elements exist
// Does NOT depend on specific credentials in the database

test.describe('Auth Pages', () => {
  test('sign in page loads with form', async ({ page }) => {
    await page.goto('/session/new')
    await expect(page.locator('#email')).toBeVisible()
    await expect(page.locator('#password_field')).toBeVisible()
  })

  test('sign up page loads with form', async ({ page }) => {
    await page.goto('/registration/new')
    await expect(page.locator('input[type="email"]')).toBeVisible()
  })

  test('welcome page loads', async ({ page }) => {
    await page.goto('/')
    await expect(page.locator('body')).not.toBeEmpty()
  })

  test('password reset page loads', async ({ page }) => {
    await page.goto('/users/password/new')
    await expect(page.locator('input[type="email"]')).toBeVisible()
  })
})

test.describe('Authenticated Pages', () => {
  test('calendar redirects to login when unauthenticated', async ({ page }) => {
    await page.goto('/calendar')
    await page.waitForURL('**/session/new', { timeout: 5000 })
  })

  test('settings redirects to login when unauthenticated', async ({ page }) => {
    await page.goto('/settings/edit')
    await page.waitForURL('**/session/new', { timeout: 5000 })
  })
})
