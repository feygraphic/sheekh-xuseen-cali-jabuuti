const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Antigravity-Adhkar-Search' } }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function searchCode(query) {
  const url = `https://api.github.com/search/code?q=${encodeURIComponent(query)}&per_page=10`;
  const res = await get(url);
  console.log(`Query: ${query} (Status: ${res.status})`);
  try {
    const j = JSON.parse(res.data);
    if (j.items) {
      j.items.forEach(item => {
        console.log(`- ${item.repository.full_name}: ${item.path}`);
      });
    } else {
      console.log('Error/No items:', res.data.substring(0, 150));
    }
  } catch(e) {
    console.error(e.message);
  }
}

async function run() {
  await searchCode('"Dhufayska Muslimka"');
  await searchCode('"Adkaarta Subaxda"');
  await searchCode('"Adkaarta Hurdada"');
  await searchCode('Hisnul Muslim Somali');
}

run();
