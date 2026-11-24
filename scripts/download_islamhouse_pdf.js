const https = require('https');
const fs = require('fs');

const url = 'https://d1.islamhouse.com/data/so/ih_books/single/so_Xisnul_Muslim.pdf';
const file = fs.createWriteStream('scripts/so_Xisnul_Muslim.pdf');

https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
  console.log('Status:', res.statusCode);
  res.pipe(file);
  file.on('finish', () => {
    file.close();
    console.log('Saved PDF, size:', fs.statSync('scripts/so_Xisnul_Muslim.pdf').size);
  });
}).on('error', err => {
  console.error(err);
});
