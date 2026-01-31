import playwright from 'playwright'

async function main(): Promise<void> { 
    const browser: playwright.Browser = await playwright.chromium.launch({
        headless: false,
        slowMo: 500,
    });
    const page: playwright.Page = await browser.newPage();
  
    await page.goto('https://www.sherdog.com/organizations/Ultimate-Fighting-Championship-UFC-2');
    const events = await page.$$eval(
        'table.new_table.event tbody tr[itemtype="http://schema.org/Event"]',
        rows =>
          rows.map(row => {
            const date =
              row
                .querySelector('meta[itemprop="startDate"]')
                ?.getAttribute('content')
                ?.split('T')[0] ?? null;
    
            const title =
              row.querySelector('[itemprop="name"]')?.textContent?.trim() ?? null;
    
            const url =
              row.querySelector('[itemprop="url"]')?.getAttribute('href') ?? null;
    
            const location =
              row.querySelector('[itemprop="location"]')?.textContent?.trim() ?? null;
    
            return { date, title, url, location };
          })
      );
    
      console.log(JSON.stringify(events, null, 2));
}

main().catch(console.error);
