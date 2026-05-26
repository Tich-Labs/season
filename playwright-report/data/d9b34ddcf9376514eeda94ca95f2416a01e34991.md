# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: auth/sign-out.spec.js >> Sign Out >> should sign out successfully
- Location: tests/auth/sign-out.spec.js:14:7

# Error details

```
Error: expect(received).toMatch(expected)

Expected pattern: /\/calendar|\/onboarding/
Received string:  "http://localhost:3000/session"
```

# Page snapshot

```yaml
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
    - alert [ref=e32]:
      - generic [ref=e33]: "!"
      - generic [ref=e34]:
        - paragraph [ref=e35]: Wrong E-mail or password.
        - paragraph [ref=e36]: Please try again.
    - button "Log In" [ref=e38] [cursor=pointer]
  - link "I am new... Sign up!" [ref=e40] [cursor=pointer]:
    - /url: /registration/new
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test'
  2  | 
  3  | test.describe('Sign Out', () => {
  4  |   test.beforeEach(async ({ page }) => {
  5  |     await page.goto('/session/new')
  6  |     await page.fill('input[name="email"]', 'test1@seasonapp.co')
  7  |     await page.fill('input[name="password"]', 'Season2026!')
  8  |     await page.click('input[type="submit"]')
  9  |     await page.waitForTimeout(3000)
  10 |     const url = page.url()
> 11 |     expect(url).toMatch(/\/calendar|\/onboarding/)
     |                 ^ Error: expect(received).toMatch(expected)
  12 |   })
  13 | 
  14 |   test('should sign out successfully', async ({ page }) => {
  15 |     await page.request.delete('/session')
  16 |     await page.waitForURL(/\/session\/new|\/welcome/)
  17 |   })
  18 | 
  19 |   test('should not access protected pages after sign out', async ({ page }) => {
  20 |     await page.request.delete('/session')
  21 |     await page.waitForURL(/\/session\/new|\/welcome/)
  22 |     await page.goto('/calendar')
  23 |     await expect(page).toHaveURL(/\/session\/new/)
  24 |   })
  25 | })
  26 | 
```