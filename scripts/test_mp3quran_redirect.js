const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        console.log(`Redirecting from ${url} to ${res.headers.location}`);
        return get(res.headers.location).then(resolve).catch(reject);
      }
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function testApi() {
  try {
    const res = await get('https://mp3quran.net/api/v3/reciters?language=ar');
    console.log('Final status:', res.status, 'length:', res.data.length);
    const json = JSON.parse(res.data);
    console.log('Reciters count:', json.reciters ? json.reciters.length : 0);
    if (json.reciters && json.reciters.length > 0) {
      json.reciters.slice(0, 5).forEach(r => {
        console.log(`- ${r.id}: ${r.name}`);
        if (r.moshaf) {
          r.moshaf.forEach(m => console.log(`   moshaf: ${m.name}, server: ${m.server}, surah_total: ${m.surah_total}`));
        }
      });
    }
  } catch(e) {
    console.error('Error:', e.message);
  }
}

testApi();
