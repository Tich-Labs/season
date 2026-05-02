import { test, expect } from '@playwright/test';

test.describe('Sign Up', () => {
  const uniqueEmail = () => `test-${Date.now()}@example.com`;

  test('should display sign up page', async ({ page }) => {
    await page.goto('/registration/new');
    await expect(page.locator('h1')).toBeVisible();
  });

  test('should sign up with valid email and password', async ({ page }) => {
    const email = uniqueEmail();
    await page.goto('/registration/new');
    await page.fill('input[name="email"]', email);
    await page.fill('input[name="password"]', 'Password123!');
    await page.fill('input[name="password_confirmation"]', 'Password123!');
    await page.click('input[type="submit"]');
    await page.waitForTimeout(3000);
    // After sign up, should redirect to check_email page
    await expect(page).toHaveURL(/\/registration\/check_email/);
  });

  test('should show error for already registered email', async ({ page }) => {
    await page.goto('/registration/new');
    await page.fill('input[name="email"]', 'test1@seasonapp.co');
    await page.fill('input[name="password"]', 'Password123!');
    await page.fill('input[name="password_confirmation"]', 'Password123!');
    await page.click('input[type="submit"]');
    await page.waitForSelector('.bg-brand-error, [role="alert"]');
  });

  test('should show error for password mismatch', async ({ page }) => {
    const email = uniqueEmail();
    await page.goto('/registration/new');
    await page.fill('input[name="email"]', email);
    await page.fill('input[name="password"]', 'Password123!');
    await page.fill('input[name="password_confirmation"]', 'Different456!');
    await page.click('input[type="submit"]');
    await page.waitForSelector('.bg-brand-error, [role="alert"]');
  });
});
