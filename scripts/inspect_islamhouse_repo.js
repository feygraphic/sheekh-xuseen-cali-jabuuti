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
  const repo = 'IslamHouse-API/iranun-maguindanaon-somali-oromo-swahili-islam-quran-hadith-data-json-api';
  let res = await get(`https://api.github.com/repos/${repo}/git/trees/main?recursive=1`);
  if (res.status !== 200) {
    res = await get(`https://api.github.com/repos/${repo}/git/trees/master?recursive=1`);
  }
  console.log('Status:', res.status);
  if (res.status === 200) {
    const tree = JSON.parse(res.data).tree || [];
    const somaliFiles = tree.filter(f => f.path.toLowerCase().includes('somali') || f.path.startsWith('so/'));
    console.log('Somali files count:', somaliFiles.length);
    somaliFiles.slice(0, 30).forEach(f => console.log(' - ' + f.path));
  }
}

run();
