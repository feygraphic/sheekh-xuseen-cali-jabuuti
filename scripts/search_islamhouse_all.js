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

async function searchIslamHouse(type) {
  const url = `https://api3.islamhouse.com/v3/paV29H2bg56DuWW/main/${type}/so/so/1/100/json`;
  const res = await get(url);
  if (res.status === 200) {
    try {
      const j = JSON.parse(res.data);
      if (j.data) {
        j.data.forEach(item => {
          const t = (item.title || '').toLowerCase();
          const d = (item.description || '').toLowerCase();
          if (t.includes('dhufays') || t.includes('xisn') || t.includes('adkaar') || t.includes('duco') || t.includes('dikri') ||
              d.includes('dhufays') || d.includes('xisn') || d.includes('adkaar') || d.includes('duco') || d.includes('dikri')) {
            console.log(`[${type}] ${item.id} - ${item.title}`);
          }
        });
      }
    } catch(e) {}
  }
}

async function run() {
  await searchIslamHouse('articles');
  await searchIslamHouse('audios');
  await searchIslamHouse('cards');
  await searchIslamHouse('apps');
}

run();
