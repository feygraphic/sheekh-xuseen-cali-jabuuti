const https = require('https');

function checkAudioUrl(url) {
  return new Promise((resolve) => {
    https.request(url, { method: 'HEAD', headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      resolve({ url, status: res.statusCode, contentType: res.headers['content-type'], contentLength: res.headers['content-length'] });
    }).on('error', err => resolve({ url, error: err.message })).end();
  });
}

async function run() {
  const r1 = await checkAudioUrl('https://cdn.mp3quran.net/audio/maher-muaiqly/r1/001.mp3');
  console.log('Result 1 (Al-Faatiha):', r1);
  const r2 = await checkAudioUrl('https://cdn.mp3quran.net/audio/maher-muaiqly/r1/002.mp3');
  console.log('Result 2 (Al-Baqarah):', r2);
  const r114 = await checkAudioUrl('https://cdn.mp3quran.net/audio/maher-muaiqly/r1/114.mp3');
  console.log('Result 114 (An-Naas):', r114);
}

run();
