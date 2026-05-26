# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: auth/password-reset.spec.js >> Password Reset >> should show done page even for non-existent email
- Location: tests/auth/password-reset.spec.js:18:7

# Error details

```
Error: expect(page).toHaveURL(expected) failed

Expected pattern: /\/password\/done/
Received string:  "http://localhost:3000/users/password"
Timeout: 5000ms

Call log:
  - Expect "toHaveURL" with timeout 5000ms
    9 × unexpected value "http://localhost:3000/users/password"

```

# Page snapshot

```yaml
- generic [ref=e2]: Retry later
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test'
  2  | 
  3  | test.describe('Password Reset', () => {
  4  |   test('should display forgot password page', async ({ page }) => {
  5  |     await page.goto('/users/password/new')
  6  |     await expect(page.locator('h1')).toContainText(/Change.*password/i)
  7  |   })
  8  | 
  9  |   test('should submit password reset request', async ({ page }) => {
  10 |     await page.goto('/users/password/new')
  11 |     await page.fill('input[name="email"]', 'test1@seasonapp.co')
  12 |     await page.click('input[type="submit"]')
  13 |     // Wait for Turbo to process
  14 |     await page.waitForTimeout(3000)
  15 |     await expect(page).toHaveURL(/\/password\/done/)
  16 |   })
  17 | 
  18 |   test('should show done page even for non-existent email', async ({ page }) => {
  19 |     await page.goto('/users/password/new')
  20 |     await page.fill('input[name="email"]', 'nonexistent@example.com')
  21 |     await page.click('input[type="submit"]')
  22 |     await page.waitForTimeout(3000)
> 23 |     await expect(page).toHaveURL(/\/password\/done/)
     |                        ^ Error: expect(page).toHaveURL(expected) failed
  24 |   })
  25 | })
  26 | 
```