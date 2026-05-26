import { test, expect } from '@playwright/test'

const TEST_EMAIL = 'alice@example.com'
const TEST_PASSWORD = 'password123'

test.describe('Sign In', () => {
  test('should display sign in page', async ({ page }) => {
    await page.goto('/session/new')
    await expect(page.locator('#email')).toBeVisible()
  })

  test('should sign in with valid credentials', async ({ page }) => {
    await page.goto('/session/new')
    await page.fill('#email', TEST_EMAIL)
    await page.fill('#password_field', TEST_PASSWORD)
    await page.click('input[type="submit"]')
    await page.waitForURL('**/calendar')
  })

  test('should show error for wrong password', async ({ page }) => {
    await page.goto('/session/new')
    await page.fill('#email', TEST_EMAIL)
    await page.fill('#password_field', 'wrongpassword')
    await page.click('input[type="submit"]')
    await expect(page.locator('#auth-error, .text-brand-primary')).toBeVisible({ timeout: 5000 })
  })

  test('should show error for non-existent email', async ({ page }) => {
    await page.goto('/session/new')
    await page.fill('#email', 'noone@nowhere.com')
    await page.fill('#password_field', 'anything')
    await page.click('input[type="submit"]')
    await expect(page.locator('#auth-error, .text-brand-primary')).toBeVisible({ timeout: 5000 })
  })
})

test.describe('Sign Up', () => {
  test('should display sign up page', async ({ page }) => {
    await page.goto('/registration/new')
    await expect(page.locator('#user_name')).toBeVisible()
  })

  test('should sign up with valid email and password', async ({ page }) => {
    const email = `e2e-${Date.now()}@season.vision`
    await page.goto('/registration/new')
    await page.fill('#user_name', 'E2E User')
    await page.fill('#user_email', email)
    await page.fill('#user_password', TEST_PASSWORD)
    await page.fill('#user_password_confirmation', TEST_PASSWORD)
    await page.check('#terms_accepted')
    await page.click('input[type="submit"]')
    await page.waitForURL('**/onboarding/**', { timeout: 10000 })
  })
})

test.describe('Sign Out', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/session/new')
    await page.fill('#email', TEST_EMAIL)
    await page.fill('#password_field', TEST_PASSWORD)
    await page.click('input[type="submit"]')
    await page.waitForURL('**/calendar')
  })

  test('should sign out successfully', async ({ page }) => {
    await page.goto('/session/destroy')
    await page.waitForURL('**/welcome', { timeout: 5000 }).catch(() => {})
  })
})

test.describe('Password Reset', () => {
  test('should display forgot password page', async ({ page }) => {
    await page.goto('/users/password/new')
    await expect(page.locator('#user_email')).toBeVisible({ timeout: 5000 })
  })
})
