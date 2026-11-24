const http = require('http');

const urls = [
  'https://sheekhxuseen.s3.us-east-005.backblazeb2.com/0004sheik+tabliq.mp3',
  'https://muxaadaro.s3.us-east-005.backblazeb2.com/Faaidooyinka+Waawayn+Laga+Helo+Istiqfaarta+Sheekh+Xuseen+Cali+Jabuuti+2025.mp3',
  'https://qisoshxsenn.s3.us-east-005.backblazeb2.com/Qiso+Maalintii+Cali+Bin+Abii+Daalib+Calanka+Loo+Dhiibay+Sh+Xuseen+Cali+Jabuuti.mp3',
  'https://muxaadaro.s3.us-east-005.backblazeb2.com/Qisada+Nabi+Yusuf+Waa+Qisada+Uga+Macaan+Aduunka+Sheekh+Xuseen+Cali+Jabuuti+2024.mp3'
];

async function test(u) {
  return new Promise((resolve) => {
    const proxyUrl = 'http://localhost:8080/audio-proxy?url=' + encodeURIComponent(u);
    http.get(proxyUrl, { headers: { 'Range': 'bytes=0-1023' } }, (res) => {
      let bytes = 0;
      res.on('data', chunk => bytes += chunk.length);
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          headers: res.headers,
          bytesReceived: bytes
        });
      });
    }).on('error', err => resolve({ error: err.message }));
  });
}

(async () => {
  for (const u of urls) {
    const r = await test(u);
    console.log('Result for:', u.split('/').pop());
    console.log('  Status:', r.status);
    console.log('  Content-Range:', r.headers['content-range']);
    console.log('  Content-Type:', r.headers['content-type']);
    console.log('  Access-Control-Allow-Origin:', r.headers['access-control-allow-origin']);
    console.log('  Bytes Received:', r.bytesReceived);
  }
})();
