// Initial version: ChatGPT 4o trying to automate PDF download
// Then 7 rounds of Cursor refactoring... bingo. It works.
// Run it:
//   node download-omaha-pdf.js <filename>
// Example:
//   node download-omaha-pdf.js 2025-04-29j.pdf

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// Helper function for delay
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

// Ensure dump directory exists
const dumpDir = path.join(__dirname, 'dump');
if (!fs.existsSync(dumpDir)) {
  fs.mkdirSync(dumpDir);
}

// Get filename from command line arguments
const filename = process.argv[2];
if (!filename) {
  console.error('❌ Please provide a filename as an argument');
  console.error('Example: node download-omaha-pdf.js 2025-04-29j.pdf');
  process.exit(1);
}

(async () => {
  const baseUrl = 'https://cityclerk.cityofomaha.org';
  const pdfUrl = `${baseUrl}/wp-content/uploads/images/${filename}`;
  
  // Launch browser with additional arguments
  const browser = await puppeteer.launch({
    headless: false, // Set to true in production
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-web-security',
      '--disable-features=IsolateOrigins,site-per-process',
      '--window-size=1920,1080',
      '--disable-pdf-viewer',
      '--disable-extensions'
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
    'Pragma': 'no-cache',
    'Origin': baseUrl,
    'Referer': `${baseUrl}/category/city-council-downloads/journals/2025-journals-journals/`
  });

  try {
    // Visit the main site first to establish cookies
    console.log('Visiting main site...');
    // await page.goto(`${baseUrl}/category/city-council-downloads/journals/2025-journals-journals/`, {
    // await page.goto(`${baseUrl}/category/city-council-downloads/journals/2025-journals-journals/page/2/`, {
    await page.goto(`${baseUrl}/category/city-council-downloads/journals/2024-journals/`, {
        waitUntil: 'networkidle2',
        timeout: 30000
    });

    // Add a small delay to ensure cookies are properly set
    console.log('Waiting for cookies to set...');
    await delay(2000);

    // Try to find the PDF link on the page
    console.log('Looking for PDF link...');
    const pdfLink = await page.evaluate((targetFilename) => {
      const links = Array.from(document.querySelectorAll('a'));
      return links.find(link => link.href.includes(targetFilename))?.href;
    }, filename);

    if (!pdfLink) {
      throw new Error(`Could not find PDF link for ${filename}`);
    }

    console.log('Found PDF link:', pdfLink);

    // Click the PDF link instead of directly accessing the URL
    console.log('Clicking PDF link...');
    await page.goto(pdfLink, {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    // Get the response from the last request
    const response = await page.evaluate(() => {
      return new Promise((resolve) => {
        const xhr = new XMLHttpRequest();
        xhr.open('GET', window.location.href, true);
        xhr.responseType = 'arraybuffer';
        xhr.onload = () => {
          resolve({
            status: xhr.status,
            headers: xhr.getAllResponseHeaders(),
            data: Array.from(new Uint8Array(xhr.response))
          });
        };
        xhr.send();
      });
    });

    console.log('Response status:', response.status);
    console.log('Response headers:', response.headers);

    // Convert the array buffer to a Buffer
    const buffer = Buffer.from(response.data);
    console.log('Response buffer length:', buffer.length);

    // Check if it's a PDF
    if (buffer.toString('ascii', 0, 5) === '%PDF-') {
      const outputPath = path.join(dumpDir, filename);
      fs.writeFileSync(outputPath, buffer);
      console.log(`✅ PDF downloaded successfully to ${outputPath}`);
      process.exit(0);
    } else {
      console.error('❌ Response is not a valid PDF');
      // Save the response for debugging
      const debugPath = path.join(dumpDir, 'debug-response.bin');
      fs.writeFileSync(debugPath, buffer);
      console.log(`Saved response to ${debugPath} for inspection`);
      
      // Log the first few bytes for debugging
      console.log('First 20 bytes:', buffer.toString('hex', 0, 20));
      process.exit(1);
    }

  } catch (error) {
    console.error('❌ An error occurred:', error.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
})();
