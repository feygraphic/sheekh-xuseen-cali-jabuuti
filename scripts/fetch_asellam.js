const https = require('https');

const url = 'https://raw.githubusercontent.com/asellam/HisnElMuslim/master/hisn.json';

https.get(url, (res) => {
  console.log('Status code:', res.statusCode);
  let raw = '';
  res.on('data', c => raw += c);
  res.on('end', () => {
    console.log('Length:', raw.length);
    try {
      const data = JSON.parse(raw);
      console.log('Is Array?', Array.isArray(data));
      if (Array.isArray(data)) {
        console.log('Count:', data.length);
        console.log('First item:', JSON.stringify(data[0], null, 2));
      } else {
        const keys = Object.keys(data);
        console.log('Keys count:', keys.length);
        console.log('Sample key item:', JSON.stringify(data[keys[0]], null, 2).substring(0, 500));
      }
    } catch (e) {
      console.error('Parse error:', e.message);
    }
  });
}).on('error', e => console.error(e.message));
