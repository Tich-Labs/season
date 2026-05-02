import { test, expect } from '@playwright/test';

test.describe('Sign In', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/session/new');
  });

  test('should display sign in page', async ({ page }) => {
    await expect(page.locator('h1')).toContainText(/LOG IN/);
  });

  test('should sign in with valid credentials', async ({ page }) => {
    await page.fill('input[name="email"]', 'test1@seasonapp.co');
    await page.fill('input[name="password"]', 'Season2026!');
    await page.click('input[type="submit"]');
    // Wait for navigation via Turbo
    await page.waitForTimeout(3000);
    const url = page.url();
    expect(url).toMatch(/\/calendar|\/onboarding/);
  });

  test('should show error for wrong password', async ({ page }) => {
    await page.fill('input[name="email"]', 'test1@seasonapp.co');
    await page.fill('input[name="password"]', 'WrongPassword!');
    await page.click('input[type="submit"]');
    await page.waitForSelector('#auth-error, .bg-brand-error');
  });

  test('should show error for non-existent email', async ({ page }) => {
    await page.fill('input[name="email"]', 'nonexistent@example.com');
    await page.fill('input[name="password"]', 'Password123!');
    await page.click('input[type="submit"]');
    await page.waitForSelector('#auth-error, .bg-brand-error');
  });

  test('should redirect authenticated user away from sign in', async ({ page }) => {
    await page.fill('input[name="email"]', 'test1@seasonapp.co');
    await page.fill('input[name="password"]', 'Season2026!');
    await page.click('input[type="submit"]');
    await page.waitForTimeout(3000);
    const url = page.url();
    expect(url).toMatch(/\/calendar|\/onboarding/);
    await page.goto('/session/new');
    await expect(page).toHaveURL(/\/calendar|\/onboarding/);
  });
});
