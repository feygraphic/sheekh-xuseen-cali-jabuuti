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
  const f1 = await get('https://raw.githubusercontent.com/Naciimo-Abdullahi/Adkaar-Flutter-App/main/lib/Model/adkaar_subax.dart');
  console.log('f1 (first 500 chars):', f1.data.substring(0, 500));
  const f2 = await get('https://raw.githubusercontent.com/Naciimo-Abdullahi/Adkaar-Flutter-App/main/lib/Pages/Adkaar_Subax.dart');
  console.log('f2 (first 500 chars):', f2.data.substring(0, 500));
}

run();
