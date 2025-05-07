// Initial version: ChatGPT 4o trying to automate PDF download
// node download-omaha-pdf.js

const puppeteer = require('puppeteer');
const fs = require('fs');

// Helper function for delay
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

(async () => {
  const url = 'https://cityclerk.cityofomaha.org/wp-content/uploads/images/2025-04-29j.pdf';
  
  // Launch browser with additional arguments
  const browser = await puppeteer.launch({
    headless: false, // Set to true in production
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-web-security',
      '--disable-features=IsolateOrigins,site-per-process',
      '--window-size=1920,1080',
      '--disable-pdf-viewer', // Disable Chrome's PDF viewer
      '--disable-extensions' // Disable Chrome extensions
    ]
  });
  
  const page = await browser.newPage();
  
  // Set viewport to a common desktop resolution
  await page.setViewport({
    width: 1920,
    height: 1080
  });
  
  // Set a realistic user agent
  await page.setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36');
  
  // Set additional headers
  await page.setExtraHTTPHeaders({
    'Accept': 'application/pdf,application/x-pdf,application/octet-stream',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache'
  });

  try {
    // Visit the main site first to establish cookies
    console.log('Visiting main site...');
    await page.goto('https://cityclerk.cityofomaha.org/category/city-council-downloads/journals/2025-journals-journals/', {
      waitUntil: 'networkidle2',
      timeout: 30000
    });

    // Add a small delay to ensure cookies are properly set
    console.log('Waiting for cookies to set...');
    await delay(2000);

    // Try accessing the PDF directly
    console.log('Attempting to download PDF...');
    const response = await page.goto(url, {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    // Get the response headers
    const headers = response.headers();
    console.log('Response headers:', headers);

    // Get the response buffer
    const buffer = await response.buffer();
    console.log('Response buffer length:', buffer.length);

    // Check if it's a PDF
    if (buffer.toString('ascii', 0, 5) === '%PDF-') {
      fs.writeFileSync('2025-04-29j.pdf', buffer);
      console.log('✅ PDF downloaded successfully.');
    } else {
      console.error('❌ Response is not a valid PDF');
      // Save the response for debugging
      fs.writeFileSync('debug-response.bin', buffer);
      console.log('Saved response to debug-response.bin for inspection');
      
      // Log the first few bytes for debugging
      console.log('First 20 bytes:', buffer.toString('hex', 0, 20));
    }

  } catch (error) {
    console.error('❌ An error occurred:', error.message);
  } finally {
    await browser.close();
  }
})();
