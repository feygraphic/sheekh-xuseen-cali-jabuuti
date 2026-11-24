const https = require('https');

const url = 'https://hisnulmuslim.org/hisnul-muslim/somali/';

https.get(url, (res) => {
  console.log('Status code:', res.statusCode);
  console.log('Location:', res.headers.location);
  let raw = '';
  res.on('data', chunk => raw += chunk);
  res.on('end', () => {
    console.log('Content length:', raw.length);
    console.log('Preview:', raw.substring(0, 1000));
  });
}).on('error', (err) => {
  console.error('Error fetching:', err.message);
});
