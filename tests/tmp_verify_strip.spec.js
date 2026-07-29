const { test } = require('@playwright/test')

test('verify cycle day strip centers today', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 800 })
  await page.goto('http://localhost:3000/session/new')
  await page.fill('#email', 'playwright.debug@example.com')
  await page.fill('#password_field', 'password123')
  await page.locator('#email-login-form input[type=submit]').click()
  await page.waitForURL('**/calendar**', { timeout: 10000 })

  await page.goto('http://localhost:3000/tracking')
  await page.waitForTimeout(500)

  const container = page.locator('[data-controller="center-scroll"]')
  const current = page.locator('[data-center-scroll-target="current"]')
  console.log('current target count:', await current.count())
  console.log('container scrollLeft:', await container.evaluate(el => el.scrollLeft))

  const containerBox = await container.boundingBox()
  const currentBox = await current.boundingBox()
  console.log('container box:', containerBox)
  console.log('current circle box:', currentBox)
  console.log('current circle center x:', currentBox.x + currentBox.width / 2, 'vs container center x:', containerBox.x + containerBox.width / 2)

  await container.screenshot({ path: '/tmp/strip_centered.png' })
})
