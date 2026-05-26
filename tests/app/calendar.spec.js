import { test, expect } from '@playwright/test'

const TEST_EMAIL = 'alice@example.com'
const TEST_PASSWORD = 'password123'

test.describe('Calendar', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/session/new')
    await page.fill('#email', TEST_EMAIL)
    await page.fill('#password_field', TEST_PASSWORD)
    await page.click('input[type="submit"]')
    await page.waitForURL('**/calendar', { timeout: 10000 })
  })

  test('shows calendar after login', async ({ page }) => {
    await expect(page.locator('text=Season')).toBeVisible({ timeout: 5000 })
  })
})

test.describe('Onboarding', () => {
  test('shows onboarding for new user', async ({ page }) => {
    const email = `e2e-${Date.now()}@season.vision`
    await page.goto('/registration/new')
    await page.fill('#user_name', 'E2E User')
    await page.fill('#user_email', email)
    await page.fill('#user_password', TEST_PASSWORD)
    await page.fill('#user_password_confirmation', TEST_PASSWORD)
    await page.check('#terms_accepted')
    await page.click('input[type="submit"]')
    await page.waitForURL('**/onboarding/**', { timeout: 10000 })
    await expect(page.locator('text=Name, Birthday')).toBeVisible({ timeout: 5000 })
  })
})
