# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: auth/sign-up.spec.js >> Sign Up >> should show error for password mismatch
- Location: tests/auth/sign-up.spec.js:32:7

# Error details

```
Test timeout of 30000ms exceeded.
```

```
Error: page.waitForSelector: Test timeout of 30000ms exceeded.
Call log:
  - waiting for locator('.bg-brand-error, [role="alert"]') to be visible

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
        - textbox "Email" [ref=e24]:
          - /placeholder: E-mail...
          - text: test-1779808789259@example.com
      - generic [ref=e25]:
        - generic [ref=e26]: Password
        - textbox "Password" [ref=e27]:
          - /placeholder: Password...
          - text: Password123!
        - button "Toggle password visibility" [ref=e28] [cursor=pointer]:
          - img [ref=e29]
      - generic [ref=e32]:
        - generic [ref=e33]: Repeat password
        - textbox "Repeat password" [ref=e34]:
          - /placeholder: Repeat password...
          - text: Different456!
        - button "Toggle password visibility" [ref=e35] [cursor=pointer]:
          - img [ref=e36]
      - generic [ref=e39]:
        - checkbox [active] [ref=e40]
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
    - generic [ref=e51]: "83.0"
    - text: ms
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test'
  2  | 
  3  | test.describe('Sign Up', () => {
  4  |   const uniqueEmail = () => `test-${Date.now()}@example.com`
  5  | 
  6  |   test('should display sign up page', async ({ page }) => {
  7  |     await page.goto('/registration/new')
  8  |     await expect(page.locator('h1')).toBeVisible()
  9  |   })
  10 | 
  11 |   test('should sign up with valid email and password', async ({ page }) => {
  12 |     const email = uniqueEmail()
  13 |     await page.goto('/registration/new')
  14 |     await page.fill('input[name="email"]', email)
  15 |     await page.fill('input[name="password"]', 'Password123!')
  16 |     await page.fill('input[name="password_confirmation"]', 'Password123!')
  17 |     await page.click('input[type="submit"]')
  18 |     await page.waitForTimeout(3000)
  19 |     // After sign up, should redirect to check_email page
  20 |     await expect(page).toHaveURL(/\/registration\/check_email/)
  21 |   })
  22 | 
  23 |   test('should show error for already registered email', async ({ page }) => {
  24 |     await page.goto('/registration/new')
  25 |     await page.fill('input[name="email"]', 'test1@seasonapp.co')
  26 |     await page.fill('input[name="password"]', 'Password123!')
  27 |     await page.fill('input[name="password_confirmation"]', 'Password123!')
  28 |     await page.click('input[type="submit"]')
  29 |     await page.waitForSelector('.bg-brand-error, [role="alert"]')
  30 |   })
  31 | 
  32 |   test('should show error for password mismatch', async ({ page }) => {
  33 |     const email = uniqueEmail()
  34 |     await page.goto('/registration/new')
  35 |     await page.fill('input[name="email"]', email)
  36 |     await page.fill('input[name="password"]', 'Password123!')
  37 |     await page.fill('input[name="password_confirmation"]', 'Different456!')
  38 |     await page.click('input[type="submit"]')
> 39 |     await page.waitForSelector('.bg-brand-error, [role="alert"]')
     |                ^ Error: page.waitForSelector: Test timeout of 30000ms exceeded.
  40 |   })
  41 | })
  42 | 
```