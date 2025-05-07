// Initial version: ChatGPT 4o trying to automate PDF download
// node download-omaha-pdf.js

const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const url = 'https://cityclerk.cityofomaha.org/wp-content/uploads/images/2025-04-29j.pdf';
  
  // Launch browser with additional arguments
  const browser = await puppeteer.launch({
    headless: false, // Set to true in production
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-web-security',
      '--disable-features=IsolateOrigins,site-per-process'
    ]
  });
  
  const page = await browser.newPage();
  
  // Set a realistic user agent
  await page.setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36');
  
  // Set additional headers
  await page.setExtraHTTPHeaders({
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1'
  });

  try {
    // Visit the main site first to establish cookies
    console.log('Visiting main site...');
    await page.goto('https://cityclerk.cityofomaha.org/category/city-council-downloads/journals/2025-journals-journals/', {
      waitUntil: 'networkidle2',
      timeout: 30000
    });

    // Try accessing the PDF
    console.log('Attempting to download PDF...');
    const pdfResponse = await page.goto(url, {
      waitUntil: 'networkidle2',
      timeout: 30000
    });

    const status = pdfResponse.status();
    if (status === 403) {
      console.error('❌ Failed to download PDF: 403 Forbidden');
      // Log response headers for debugging
      const headers = pdfResponse.headers();
      console.log('Response headers:', headers);
    } else if (status !== 200) {
      console.error(`❌ Failed to download PDF: HTTP ${status}`);
    } else {
      const buffer = await pdfResponse.buffer();
      fs.writeFileSync('2025-04-29j.pdf', buffer);
      console.log('✅ PDF downloaded successfully.');
    }
  } catch (error) {
    console.error('❌ An error occurred:', error.message);
  } finally {
    await browser.close();
  }
})();
