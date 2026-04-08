const { chromium } = require('playwright');

const SCREENS = [
  { url: '/', name: '01-loader' },
  { url: '/welcome', name: '02-welcome' },
  { url: '/registration/new', name: '03-signup' },
  { url: '/session/new', name: '04-login' },
  { url: '/calendar', name: '05-calendar' },
  { url: '/daily/2026-04-07', name: '06-daily' },
  { url: '/tracking', name: '07-tracking' },
  { url: '/symptoms', name: '08-symptoms' },
  { url: '/superpowers', name: '09-superpowers' },
  { url: '/streaks', name: '10-streaks' },
  { url: '/settings/edit', name: '11-settings' },
];

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 430, height: 932 } });
  
  for (const screen of SCREENS) {
    try {
      await page.goto(`http://localhost:3000${screen.url}`, { waitUntil: 'networkidle', timeout: 10000 });
      await page.screenshot({ path: `test/screenshots/${screen.name}.png`, fullPage: true });
      console.log(`✓ ${screen.name}`);
    } catch (e) {
      console.log(`✗ ${screen.name}: ${e.message}`);
    }
  }
  
  await browser.close();
})();