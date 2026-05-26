const { test, expect } = require('@playwright/test')

test.describe('Pages', () => {
  test('path config endpoint returns JSON', async ({ page }) => {
    const response = await page.goto('/configurations/ios_v1.json')
    expect(response.status()).toBe(200)
    const json = await response.json()
    expect(json.rules).toBeDefined()
    expect(json.settings.tab_bar_tint_color).toBe('#933a35')
  })

  test('android path config endpoint returns JSON', async ({ page }) => {
    const response = await page.goto('/configurations/android_v1.json')
    expect(response.status()).toBe(200)
  })

  test('health check returns 200', async ({ page }) => {
    const response = await page.goto('/up', { timeout: 5000 })
    expect(response.status()).toBe(200) || expect(response.ok()).toBeTruthy()
  })
})
