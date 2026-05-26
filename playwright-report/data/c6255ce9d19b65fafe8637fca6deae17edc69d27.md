# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app/calendar.spec.js >> Calendar >> shows calendar after login
- Location: tests/app/calendar.spec.js:12:7

# Error details

```
Test timeout of 30000ms exceeded while running "beforeEach" hook.
```

```
Error: page.waitForURL: Test timeout of 30000ms exceeded.
=========================== logs ===========================
waiting for navigation to "**/calendar" until "load"
  navigated to "http://localhost:3000/session/new"
============================================================
```

# Page snapshot

```yaml
- generic [ref=e1]:
  - generic [ref=e2]:
    - heading "Log In" [level=1] [ref=e4]
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
        - textbox "Email" [active] [ref=e22]:
          - /placeholder: E-mail...
      - generic [ref=e23]:
        - generic [ref=e24]: Password
        - textbox "Password" [ref=e25]:
          - /placeholder: Password...
        - button "Toggle password visibility" [ref=e26] [cursor=pointer]:
          - img [ref=e27]
      - link "I forgot my password..." [ref=e31] [cursor=pointer]:
        - /url: /users/password/new
      - paragraph [ref=e33]: Authentication failed. Please try again.
      - button "Log In" [ref=e35] [cursor=pointer]
    - link "I am new... Sign up!" [ref=e37] [cursor=pointer]:
      - /url: /registration/new
  - generic [ref=e40] [cursor=pointer]:
    - generic [ref=e41]: "960.7"
    - text: ms×3
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test'
  2  | 
  3  | test.describe('Calendar', () => {
  4  |   test.beforeEach(async ({ page }) => {
  5  |     await page.goto('/session/new')
  6  |     await page.fill('input[name="email"]', 'test@season.vision')
  7  |     await page.fill('input[name="password"]', 'password123')
  8  |     await page.click('button[type="submit"]')
> 9  |     await page.waitForURL('**/calendar')
     |                ^ Error: page.waitForURL: Test timeout of 30000ms exceeded.
  10 |   })
  11 | 
  12 |   test('shows calendar after login', async ({ page }) => {
  13 |     await expect(page.locator('text=Season')).toBeVisible()
  14 |   })
  15 | })
  16 | 
  17 | test.describe('Onboarding', () => {
  18 |   test('shows onboarding for new user', async ({ page }) => {
  19 |     // Sign up as a new user (uses random email to ensure fresh state)
  20 |     const email = `test-${Date.now()}@season.vision`
  21 |     await page.goto('/registration/new')
  22 |     await page.fill('input[name="name"]', 'Test User')
  23 |     await page.fill('input[name="email"]', email)
  24 |     await page.fill('input[name="password"]', 'password123')
  25 |     await page.fill('input[name="password_confirmation"]', 'password123')
  26 |     await page.check('input[name="terms_accepted"]')
  27 |     await page.click('button[type="submit"]')
  28 |     await page.waitForURL('**/onboarding/**')
  29 |     await expect(page.locator('text=Name')).toBeVisible()
  30 |   })
  31 | })
  32 | 
```