const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function run() {
  try {
    const res = await get('https://api3.islamhouse.com/v3/paV29H2bg56DuWW/main/show/380108/so/json');
    console.log('Status:', res.status);
    const j = JSON.parse(res.data);
    console.log('Title:', j.title);
    console.log('Description:', j.description ? j.description.substring(0, 200) : 'None');
    console.log('Prepared by:', JSON.stringify(j.prepared_by));
    console.log('Attachments count:', j.attachments ? j.attachments.length : 0);
    if (j.attachments) {
      j.attachments.forEach(a => console.log('Attachment:', a.extension, a.url_type, a.url, a.description));
    }
    if (j.content) {
      console.log('Has content, length:', j.content.length);
    }
  } catch (err) {
    console.error('Error:', err.message);
  }
}

run();
