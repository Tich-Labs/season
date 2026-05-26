import { test, expect } from '@playwright/test'

test.describe('Calendar', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/session/new')
    await page.fill('input[name="email"]', 'test@season.vision')
    await page.fill('input[name="password"]', 'password123')
    await page.click('button[type="submit"]')
    await page.waitForURL('**/calendar')
  })

  test('shows calendar after login', async ({ page }) => {
    await expect(page.locator('text=Season')).toBeVisible()
  })
})

test.describe('Onboarding', () => {
  test('shows onboarding for new user', async ({ page }) => {
    // Sign up as a new user (uses random email to ensure fresh state)
    const email = `test-${Date.now()}@season.vision`
    await page.goto('/registration/new')
    await page.fill('input[name="name"]', 'Test User')
    await page.fill('input[name="email"]', email)
    await page.fill('input[name="password"]', 'password123')
    await page.fill('input[name="password_confirmation"]', 'password123')
    await page.check('input[name="terms_accepted"]')
    await page.click('button[type="submit"]')
    await page.waitForURL('**/onboarding/**')
    await expect(page.locator('text=Name')).toBeVisible()
  })
})
