# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: auth/password-reset.spec.js >> Password Reset >> should submit password reset request
- Location: tests/auth/password-reset.spec.js:9:7

# Error details

```
Error: expect(page).toHaveURL(expected) failed

Expected pattern: /\/password\/done/
Received string:  "http://localhost:3000/users/password/new"
Timeout: 5000ms

Call log:
  - Expect "toHaveURL" with timeout 5000ms
    9 × unexpected value "http://localhost:3000/users/password/new"

```

# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - generic [ref=e2]:
    - link "‹ back" [ref=e4] [cursor=pointer]:
      - /url: /session/new
    - generic [ref=e5]:
      - heading "Change password" [level=1] [ref=e6]:
        - text: Change
        - text: password
      - generic [ref=e8]:
        - generic [ref=e9]: Email
        - textbox "Email" [ref=e10]:
          - /placeholder: E–mail...
          - text: test1@seasonapp.co
        - button "Forgot password" [disabled] [ref=e12] [cursor=pointer]
      - link "I'm new — Sign up!" [ref=e14] [cursor=pointer]:
        - /url: /registration/new
  - generic [ref=e17] [cursor=pointer]:
    - generic [ref=e18]: "23745.7"
    - text: ms×7
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test';
  2  | 
  3  | test.describe('Password Reset', () => {
  4  |   test('should display forgot password page', async ({ page }) => {
  5  |     await page.goto('/users/password/new');
  6  |     await expect(page.locator('h1')).toContainText(/Change.*password/i);
  7  |   });
  8  | 
  9  |   test('should submit password reset request', async ({ page }) => {
  10 |     await page.goto('/users/password/new');
  11 |     await page.fill('input[name="email"]', 'test1@seasonapp.co');
  12 |     await page.click('input[type="submit"]');
  13 |     // Wait for Turbo to process
  14 |     await page.waitForTimeout(3000);
> 15 |     await expect(page).toHaveURL(/\/password\/done/);
     |                        ^ Error: expect(page).toHaveURL(expected) failed
  16 |   });
  17 | 
  18 |   test('should show done page even for non-existent email', async ({ page }) => {
  19 |     await page.goto('/users/password/new');
  20 |     await page.fill('input[name="email"]', 'nonexistent@example.com');
  21 |     await page.click('input[type="submit"]');
  22 |     await page.waitForTimeout(3000);
  23 |     await expect(page).toHaveURL(/\/password\/done/);
  24 |   });
  25 | });
  26 | 
```