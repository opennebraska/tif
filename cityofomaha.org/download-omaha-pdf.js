// Initial version: ChatGPT 4o trying to automate PDF download
// node download-omaha-pdf.js

const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const url = 'https://cityclerk.cityofomaha.org/wp-content/uploads/images/2025-04-29j.pdf';
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  try {
    // Visit the main site to set cookies if needed
    await page.goto('https://cityclerk.cityofomaha.org/category/city-council-downloads/journals/2025-journals-journals/', {
      waitUntil: 'networkidle2'
    });

    // Try accessing the PDF
    const pdfResponse = await page.goto(url, {
      waitUntil: 'networkidle2'
    });

    const status = pdfResponse.status();
    if (status === 403) {
      console.error('❌ Failed to download PDF: 403 Forbidden');
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
