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

async function searchGithub(query) {
  const url = `https://api.github.com/search/repositories?q=${encodeURIComponent(query)}&per_page=10`;
  const res = await get(url);
  console.log(`Query: ${query} (Status: ${res.status})`);
  try {
    const j = JSON.parse(res.data);
    if (j.items) {
      j.items.forEach(item => {
        console.log(`- ${item.full_name}: ${item.description || 'No description'} (stars: ${item.stargazers_count})`);
      });
    } else {
      console.log('No items or error:', res.data.substring(0, 150));
    }
  } catch(e) {
    console.error(e.message);
  }
}

async function run() {
  await searchGithub('Dhufayska');
  await searchGithub('hisnul muslim somali');
  await searchGithub('adkar somali');
  await searchGithub('adkaarta');
}

run();
