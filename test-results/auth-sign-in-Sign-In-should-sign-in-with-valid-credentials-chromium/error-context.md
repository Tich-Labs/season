# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: auth/sign-in.spec.js >> Sign In >> should sign in with valid credentials
- Location: tests/auth/sign-in.spec.js:12:7

# Error details

```
Error: expect(received).toMatch(expected)

Expected pattern: /\/calendar|\/onboarding/
Received string:  "http://localhost:3000/session/new"
```

# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - generic [ref=e2]:
    - heading "LOG IN" [level=1] [ref=e4]
    - generic [ref=e5]:
      - paragraph [ref=e6]: "Use the fast lane:"
      - generic [ref=e7]:
        - button "Sign in with Apple" [ref=e9] [cursor=pointer]:
          - img "Apple" [ref=e10]
        - button "Sign in with Facebook" [ref=e12] [cursor=pointer]:
          - img "Facebook" [ref=e13]
        - button "Sign in with Google" [ref=e15] [cursor=pointer]:
          - img "Google" [ref=e16]
    - generic [ref=e17]: ... or login with your E-mail
    - generic [ref=e19]:
      - generic [ref=e20]:
        - generic [ref=e21]: Email
        - textbox "Email" [ref=e22]:
          - /placeholder: E-mail...
          - text: test1@seasonapp.co
      - generic [ref=e23]:
        - generic [ref=e24]: Password
        - textbox "Password" [ref=e25]:
          - /placeholder: Password...
          - text: Season2026!
        - button "Toggle password visibility" [ref=e26] [cursor=pointer]:
          - img [ref=e27]
      - link "I forgot my password..." [ref=e31] [cursor=pointer]:
        - /url: /users/password/new
      - button "Log In" [disabled] [ref=e33] [cursor=pointer]
    - link "I am new... Sign up!" [ref=e35] [cursor=pointer]:
      - /url: /registration/new
  - generic [ref=e38] [cursor=pointer]:
    - generic [ref=e39]: "882.8"
    - text: ms×2
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test';
  2  | 
  3  | test.describe('Sign In', () => {
  4  |   test.beforeEach(async ({ page }) => {
  5  |     await page.goto('/session/new');
  6  |   });
  7  | 
  8  |   test('should display sign in page', async ({ page }) => {
  9  |     await expect(page.locator('h1')).toContainText(/LOG IN/);
  10 |   });
  11 | 
  12 |   test('should sign in with valid credentials', async ({ page }) => {
  13 |     await page.fill('input[name="email"]', 'test1@seasonapp.co');
  14 |     await page.fill('input[name="password"]', 'Season2026!');
  15 |     await page.click('input[type="submit"]');
  16 |     // Wait for navigation via Turbo
  17 |     await page.waitForTimeout(3000);
  18 |     const url = page.url();
> 19 |     expect(url).toMatch(/\/calendar|\/onboarding/);
     |                 ^ Error: expect(received).toMatch(expected)
  20 |   });
  21 | 
  22 |   test('should show error for wrong password', async ({ page }) => {
  23 |     await page.fill('input[name="email"]', 'test1@seasonapp.co');
  24 |     await page.fill('input[name="password"]', 'WrongPassword!');
  25 |     await page.click('input[type="submit"]');
  26 |     await page.waitForSelector('#auth-error, .bg-brand-error');
  27 |   });
  28 | 
  29 |   test('should show error for non-existent email', async ({ page }) => {
  30 |     await page.fill('input[name="email"]', 'nonexistent@example.com');
  31 |     await page.fill('input[name="password"]', 'Password123!');
  32 |     await page.click('input[type="submit"]');
  33 |     await page.waitForSelector('#auth-error, .bg-brand-error');
  34 |   });
  35 | 
  36 |   test('should redirect authenticated user away from sign in', async ({ page }) => {
  37 |     await page.fill('input[name="email"]', 'test1@seasonapp.co');
  38 |     await page.fill('input[name="password"]', 'Season2026!');
  39 |     await page.click('input[type="submit"]');
  40 |     await page.waitForTimeout(3000);
  41 |     const url = page.url();
  42 |     expect(url).toMatch(/\/calendar|\/onboarding/);
  43 |     await page.goto('/session/new');
  44 |     await expect(page).toHaveURL(/\/calendar|\/onboarding/);
  45 |   });
  46 | });
  47 | 
```