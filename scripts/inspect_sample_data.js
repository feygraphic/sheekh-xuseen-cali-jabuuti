const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Antigravity-Adhkar-Search' } }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function run() {
  const r1 = await get('https://raw.githubusercontent.com/muraa-p/noor-guidance/main/public/data/adkar.json');
  console.log('r1 status:', r1.status, 'length:', r1.data.length);
  if (r1.status === 200) {
    try {
      const j = JSON.parse(r1.data);
      console.log('r1 keys/length:', Array.isArray(j) ? j.length : Object.keys(j));
      if (Array.isArray(j)) {
        console.log('Sample r1[0]:', JSON.stringify(j[0], null, 2));
      } else {
        const firstKey = Object.keys(j)[0];
        console.log('Sample r1 key:', firstKey, JSON.stringify(j[firstKey], null, 2));
      }
    } catch(e) {
      console.log('r1 parse error:', e.message);
    }
  }

  const r2 = await get('https://raw.githubusercontent.com/Abdiaziz2001/Jannah_Mobile_App/main/lib/ducooyin.dart');
  console.log('r2 status:', r2.status, 'length:', r2.data.length);
  if (r2.status === 200) {
    console.log('Sample r2 snippet:', r2.data.substring(0, 500));
  }
}

run();
