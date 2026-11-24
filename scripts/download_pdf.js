const https = require('https');
const fs = require('fs');
const path = require('path');

const url = 'https://hisnulmuslim.org/wp-content/uploads/2025/06/somali-hisnul-muslm.pdf';
const dest = path.join(__dirname, 'somali_hisnul_muslim.pdf');

const file = fs.createWriteStream(dest);

https.get(url, (res) => {
  console.log('Status code:', res.statusCode);
  console.log('Headers:', res.headers);
  res.pipe(file);
  file.on('finish', () => {
    file.close();
    console.log('PDF downloaded successfully, size:', fs.statSync(dest).size);
  });
}).on('error', (err) => {
  console.error('Error downloading PDF:', err.message);
});
