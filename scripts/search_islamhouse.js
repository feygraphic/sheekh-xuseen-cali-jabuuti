const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function run() {
  try {
    const res = await get('https://api3.islamhouse.com/v3/paV29H2bg56DuWW/main/books/so/so/1/50/json');
    console.log('Status:', res.status);
    const j = JSON.parse(res.data);
    console.log('Total items:', j.data ? j.data.length : 0);
    if (j.data) {
      j.data.forEach(item => {
        if (item.title && (item.title.toLowerCase().includes('dhufays') || item.title.toLowerCase().includes('xisn') || item.title.toLowerCase().includes('adkaar') || item.title.toLowerCase().includes('duco'))) {
          console.log('MATCH:', item.id, item.title, item.prepared_by ? item.prepared_by.map(p => p.title).join(', ') : '');
        }
      });
    }
  } catch (err) {
    console.error('Error:', err.message);
  }
}

run();
