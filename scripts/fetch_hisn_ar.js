const https = require('https');

https.get('https://raw.githubusercontent.com/wafaaelmaandy/Hisn-Muslim-Json/master/hisn_ar.json', (res) => {
  console.log('Status:', res.statusCode);
  let d = '';
  res.on('data', c => d += c);
  res.on('end', () => {
    console.log('Length:', d.length);
    try {
      const j = JSON.parse(d);
      const keys = Object.keys(j);
      console.log('Chapters count:', keys.length);
      console.log('Sample chapters:', keys.slice(0, 5));
      if (keys.length > 0) {
        console.log('Sample item from first chapter:', JSON.stringify(j[keys[0]][0], null, 2));
      }
    } catch (e) {
      console.error(e.message);
    }
  });
}).on('error', e => console.error(e.message));
