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
      '--window-size=1920,1080'
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
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/pdf',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
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

    // Try accessing the PDF
    console.log('Attempting to download PDF...');
    await page.goto(url, {
      waitUntil: 'networkidle2',
      timeout: 30000
    });

    // Wait for the iframe to load
    console.log('Waiting for PDF viewer to load...');
    await delay(3000);

    // Get all iframes and log their details
    const frames = await page.frames();
    console.log('Found frames:', frames.length);
    
    // Log details about each frame
    for (let i = 0; i < frames.length; i++) {
      const frame = frames[i];
      console.log(`Frame ${i}:`, {
        url: frame.url(),
        name: frame.name(),
        parentFrame: frame.parentFrame() ? 'Has parent' : 'No parent'
      });
    }

    // Look for the PDF iframe - try different methods
    let pdfFrame = frames.find(frame => frame.url().includes('about:blank'));
    if (!pdfFrame) {
      pdfFrame = frames.find(frame => frame.name().includes('PDF'));
    }
    if (!pdfFrame) {
      pdfFrame = frames.find(frame => frame.url().includes('pdf'));
    }
    
    if (!pdfFrame) {
      // If we still can't find the frame, try to get the page content
      const pageContent = await page.content();
      console.log('Page content preview:', pageContent.substring(0, 500));
      throw new Error('Could not find PDF iframe');
    }

    console.log('Found PDF frame:', {
      url: pdfFrame.url(),
      name: pdfFrame.name()
    });

    // Wait for the PDF to load in the iframe
    console.log('Waiting for PDF to load in iframe...');
    await delay(3000);

    // Try to get the PDF content
    let pdfContent;
    try {
      pdfContent = await pdfFrame.content();
      console.log('PDF content length:', pdfContent.length);
    } catch (error) {
      console.log('Error getting frame content:', error.message);
      // Try to get the frame's HTML
      pdfContent = await page.evaluate(() => {
        const iframe = document.querySelector('iframe');
        return iframe ? iframe.outerHTML : 'No iframe found';
      });
      console.log('Frame HTML:', pdfContent);
    }

    // Save the PDF content
    if (pdfContent && pdfContent.startsWith('%PDF-')) {
      fs.writeFileSync('2025-04-29j.pdf', pdfContent);
      console.log('✅ PDF downloaded successfully.');
    } else {
      console.error('❌ Downloaded content is not a valid PDF');
      fs.writeFileSync('debug-response.bin', pdfContent);
      console.log('Saved response to debug-response.bin for inspection');
    }

  } catch (error) {
    console.error('❌ An error occurred:', error.message);
  } finally {
    await browser.close();
  }
})();
