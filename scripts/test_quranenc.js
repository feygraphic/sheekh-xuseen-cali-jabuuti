const https = require('https');

https.get('https://quranenc.com/api/v1/translation/sura/somali_yacob/1', (res) => {
  let raw = '';
  res.on('data', c => raw += c);
  res.on('end', () => {
    const data = JSON.parse(raw);
    for (const a of data.result) {
      console.log(`${a.aya}: ${a.arabic_text} -> ${a.translation}`);
    }
  });
}).on('error', (e) => {
  console.error('Error:', e.message);
});
