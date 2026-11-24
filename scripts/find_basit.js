const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return get(res.headers.location).then(resolve).catch(reject);
      }
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function run() {
  const res = await get('https://www.mp3quran.net/api/v3/reciters?language=ar');
  const arReciters = JSON.parse(res.data).reciters;
  const basit = arReciters.filter(r => r.name.includes('باسط'));
  console.log('Basit reciters:');
  basit.forEach(b => {
    console.log(b.id, b.name);
    b.moshaf.forEach(m => console.log('  ', m.name, m.server, m.surah_total));
  });
}

run();
