import { test, expect } from '@playwright/test';

test.describe('Password Reset', () => {
  test('should display forgot password page', async ({ page }) => {
    await page.goto('/users/password/new');
    await expect(page.locator('h1')).toContainText(/Change.*password/i);
  });

  test('should submit password reset request', async ({ page }) => {
    await page.goto('/users/password/new');
    await page.fill('input[name="email"]', 'test1@seasonapp.co');
    await page.click('input[type="submit"]');
    // Wait for Turbo to process
    await page.waitForTimeout(3000);
    await expect(page).toHaveURL(/\/password\/done/);
  });

  test('should show done page even for non-existent email', async ({ page }) => {
    await page.goto('/users/password/new');
    await page.fill('input[name="email"]', 'nonexistent@example.com');
    await page.click('input[type="submit"]');
    await page.waitForTimeout(3000);
    await expect(page).toHaveURL(/\/password\/done/);
  });
});
