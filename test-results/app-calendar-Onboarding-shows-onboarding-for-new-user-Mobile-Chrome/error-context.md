# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app/calendar.spec.js >> Onboarding >> shows onboarding for new user
- Location: tests/app/calendar.spec.js:18:7

# Error details

```
Test timeout of 30000ms exceeded.
```

```
Error: page.fill: Test timeout of 30000ms exceeded.
Call log:
  - waiting for locator('input[name="name"]')

```

# Page snapshot

```yaml
- generic [ref=e1]:
  - generic [ref=e2]:
    - heading "SIGN UP" [level=1] [ref=e4]
    - paragraph [ref=e6]: Create an account to track your cycle
    - generic [ref=e7]:
      - paragraph [ref=e8]: "Use the fast lane:"
      - generic [ref=e9]:
        - button "Sign up with Apple" [ref=e11] [cursor=pointer]:
          - img "Apple" [ref=e12]
        - button "Sign up with Facebook" [ref=e14] [cursor=pointer]:
          - img "Facebook" [ref=e15]
        - button "Sign up with Google" [ref=e17] [cursor=pointer]:
          - img "Google" [ref=e18]
    - generic [ref=e19]: "...or sign up with your E-mail:"
    - generic [ref=e21]:
      - generic [ref=e22]:
        - generic [ref=e23]: Email
        - textbox "Email" [active] [ref=e24]:
          - /placeholder: E-mail...
      - generic [ref=e25]:
        - generic [ref=e26]: Password
        - textbox "Password" [ref=e27]:
          - /placeholder: Password...
        - button "Toggle password visibility" [ref=e28] [cursor=pointer]:
          - img [ref=e29]
      - generic [ref=e32]:
        - generic [ref=e33]: Repeat password
        - textbox "Repeat password" [ref=e34]:
          - /placeholder: Repeat password...
        - button "Toggle password visibility" [ref=e35] [cursor=pointer]:
          - img [ref=e36]
      - generic [ref=e39]:
        - checkbox [ref=e40]
        - generic [ref=e41]:
          - text: I'll accept the
          - link "terms of use" [ref=e42] [cursor=pointer]:
            - /url: /terms
          - text: and the
          - link "privacy policy" [ref=e43] [cursor=pointer]:
            - /url: /privacy
      - button "Create account" [ref=e45] [cursor=pointer]
    - link "I already have an account" [ref=e47] [cursor=pointer]:
      - /url: /session/new
  - generic [ref=e50] [cursor=pointer]:
    - generic [ref=e51]: "79.5"
    - text: ms
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
  9  |     await page.waitForURL('**/calendar')
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
> 22 |     await page.fill('input[name="name"]', 'Test User')
     |                ^ Error: page.fill: Test timeout of 30000ms exceeded.
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