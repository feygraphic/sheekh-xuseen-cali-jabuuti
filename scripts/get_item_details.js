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
  const res = await get('https://api3.islamhouse.com/v3/paV29H2bg56DuWW/main/books/so/so/1/50/json');
  const j = JSON.parse(res.data);
  const item = j.data.find(d => d.id === 380108);
  console.log(JSON.stringify(item, null, 2));
}

run();
