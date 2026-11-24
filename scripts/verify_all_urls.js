const fs = require('fs');
const https = require('https');
const http = require('http');

const csvPath = 'assets/data/raw_lectures.csv';
const content = fs.readFileSync(csvPath, 'utf8');
const lines = content.split(/\r?\n/).filter(line => line.trim().length > 0);

const items = [];
for (let i = 1; i < lines.length; i++) {
  const parts = lines[i].trim().split(',');
  const cat = parseInt(parts[parts.length - 1].trim(), 10);
  const somaliTitle = parts[0].trim();
  const arabicTitle = parts[1].trim();
  const url = parts.slice(2, parts.length - 1).join(',').trim();
  items.push({ index: i, cat, somaliTitle, arabicTitle, url });
}

console.log(`Total CSV items: ${items.length}`);

const uniqueUrls = [...new Set(items.map(it => it.url))];
console.log(`Unique URLs to verify: ${uniqueUrls.length}`);

async function checkUrl(url, timeoutMs = 8000) {
  return new Promise((resolve) => {
    try {
      const parsed = new URL(url);
      const req = https.request({
        method: 'HEAD',
        hostname: parsed.hostname,
        path: parsed.pathname + (parsed.search || ''),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        },
        timeout: timeoutMs,
      }, (res) => {
        resolve({
          url,
          statusCode: res.statusCode,
          contentType: res.headers['content-type'],
          contentLength: res.headers['content-length'],
          acceptRanges: res.headers['accept-ranges'],
          statusMessage: res.statusMessage,
        });
      });

      req.on('error', (err) => {
        resolve({ url, error: err.message });
      });

      req.on('timeout', () => {
        req.destroy();
        resolve({ url, error: 'Timeout' });
      });

      req.end();
    } catch (e) {
      resolve({ url, error: e.message });
    }
  });
}

async function verifyAll() {
  console.log('Starting parallel verification (batches of 10)...');
  const results = [];
  const batchSize = 10;
  for (let i = 0; i < uniqueUrls.length; i += batchSize) {
    const batch = uniqueUrls.slice(i, i + batchSize);
    const batchResults = await Promise.all(batch.map(u => checkUrl(u)));
    results.push(...batchResults);
    process.stdout.write(`Verified ${results.length}/${uniqueUrls.length}\r`);
  }
  console.log(`\nCompleted verification of ${results.length} URLs.`);

  const status200 = results.filter(r => r.statusCode === 200);
  const status206 = results.filter(r => r.statusCode === 206);
  const status401 = results.filter(r => r.statusCode === 401);
  const status403 = results.filter(r => r.statusCode === 403);
  const status404 = results.filter(r => r.statusCode === 404);
  const failed = results.filter(r => !r.statusCode || (r.statusCode >= 400));

  console.log(`HTTP 200 OK: ${status200.length}`);
  console.log(`HTTP 206: ${status206.length}`);
  console.log(`HTTP 401 Unauthorized: ${status401.length}`);
  console.log(`HTTP 403 Forbidden: ${status403.length}`);
  console.log(`HTTP 404 Not Found: ${status404.length}`);
  console.log(`Errors / Other: ${failed.length - status401.length - status403.length - status404.length}`);

  if (failed.length > 0) {
    console.log('\nFailed URLs:');
    failed.forEach(f => {
      console.log(`- [Status ${f.statusCode || 'ERR'}] ${f.url} : ${f.error || f.statusMessage}`);
    });
  }

  // Save report to scratch
  fs.writeFileSync('scripts/url_verification_report.json', JSON.stringify({
    totalRows: items.length,
    uniqueUrlsCount: uniqueUrls.length,
    successCount: status200.length + status206.length,
    failedCount: failed.length,
    results,
  }, null, 2));
}

verifyAll();
