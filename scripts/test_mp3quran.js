const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function testApi() {
  console.log('Testing MP3Quran API...');
  
  // 1. Reciters endpoint (in Arabic or English or Somali)
  try {
    const res = await get('https://mp3quran.net/api/v3/reciters?language=ar');
    console.log('Reciters (ar) status:', res.status);
    if (res.status === 200) {
      const json = JSON.parse(res.data);
      console.log('Total reciters:', json.reciters ? json.reciters.length : 0);
      if (json.reciters && json.reciters.length > 0) {
        // Show first 5 reciters
        json.reciters.slice(0, 5).forEach(r => {
          console.log(`ID: ${r.id}, Name: ${r.name}, Moshaf count: ${r.moshaf ? r.moshaf.length : 0}`);
          if (r.moshaf && r.moshaf.length > 0) {
            console.log(`   Sample Moshaf server: ${r.moshaf[0].server}, surah_total: ${r.moshaf[0].surah_total}, surah_list: ${r.moshaf[0].surah_list ? r.moshaf[0].surah_list.substring(0, 30) : ''}`);
          }
        });
      }
    }
  } catch(e) {
    console.error('Error testing reciters:', e.message);
  }

  // 2. English reciters endpoint
  try {
    const resEng = await get('https://mp3quran.net/api/v3/reciters?language=eng');
    console.log('Reciters (eng) status:', resEng.status);
    if (resEng.status === 200) {
      const json = JSON.parse(resEng.data);
      console.log('Total eng reciters:', json.reciters ? json.reciters.length : 0);
      // Find famous reciters like Mishary Rashid Alafasy, Abdul Basit, Al-Sudais, Maher Al-Muaiqly
      const famous = ['mishary', 'basit', 'sudais', 'muaiqly', 'ghamadi', 'husary', 'minshawi', 'ajmy', 'shuraym', 'dossari'];
      json.reciters.forEach(r => {
        const nameLower = r.name.toLowerCase();
        if (famous.some(f => nameLower.includes(f))) {
          console.log(`Famous match: ID ${r.id}: ${r.name} (server: ${r.moshaf && r.moshaf[0] ? r.moshaf[0].server : 'none'})`);
        }
      });
    }
  } catch(e) {
    console.error('Error testing eng reciters:', e.message);
  }
}

testApi();
