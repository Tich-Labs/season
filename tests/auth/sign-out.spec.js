import { test, expect } from '@playwright/test';

test.describe('Sign Out', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/session/new');
    await page.fill('input[name="email"]', 'test1@seasonapp.co');
    await page.fill('input[name="password"]', 'Season2026!');
    await page.click('input[type="submit"]');
    await page.waitForTimeout(3000);
    const url = page.url();
    expect(url).toMatch(/\/calendar|\/onboarding/);
  });

  test('should sign out successfully', async ({ page }) => {
    await page.request.delete('/session');
    await page.waitForURL(/\/session\/new|\/welcome/);
  });

  test('should not access protected pages after sign out', async ({ page }) => {
    await page.request.delete('/session');
    await page.waitForURL(/\/session\/new|\/welcome/);
    await page.goto('/calendar');
    await expect(page).toHaveURL(/\/session\/new/);
  });
});
