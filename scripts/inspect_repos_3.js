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

async function inspect(repo) {
  console.log(`\n=== Trees for ${repo} ===`);
  let res = await get(`https://api.github.com/repos/${repo}/git/trees/main?recursive=1`);
  if (res.status !== 200) {
    res = await get(`https://api.github.com/repos/${repo}/git/trees/master?recursive=1`);
  }
  if (res.status === 200) {
    const tree = JSON.parse(res.data).tree || [];
    const files = tree.filter(f => f.path.includes('adhkar') || f.path.includes('azkar') || f.path.includes('duco') || f.path.endsWith('.json'));
    console.log(`Found ${files.length} matching files:`);
    files.slice(0, 25).forEach(f => console.log(' - ' + f.path));
  } else {
    console.log(`Error ${res.status}`);
  }
}

async function run() {
  await inspect('muraa-p/noor-guidance');
  await inspect('Abdiaziz2001/Jannah_Mobile_App');
}

run();
