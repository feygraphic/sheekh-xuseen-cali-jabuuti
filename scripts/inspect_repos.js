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

async function inspectRepo(repo) {
  console.log(`=== Inspecting ${repo} ===`);
  const res = await get(`https://api.github.com/repos/${repo}/git/trees/main?recursive=1`);
  if (res.status === 200) {
    const tree = JSON.parse(res.data).tree;
    const interesting = tree.filter(f => f.path.endsWith('.json') || f.path.endsWith('.dart') || f.path.includes('data') || f.path.includes('assets') || f.path.includes('adhkar') || f.path.includes('adkar'));
    console.log('Interesting files:', interesting.map(f => f.path));
  } else {
    // try master
    const res2 = await get(`https://api.github.com/repos/${repo}/git/trees/master?recursive=1`);
    if (res2.status === 200) {
      const tree = JSON.parse(res2.data).tree;
      const interesting = tree.filter(f => f.path.endsWith('.json') || f.path.endsWith('.dart') || f.path.includes('data') || f.path.includes('assets') || f.path.includes('adhkar') || f.path.includes('adkar'));
      console.log('Interesting files:', interesting.map(f => f.path));
    } else {
      console.log('Failed:', res.status, res2.status);
    }
  }
}

async function run() {
  await inspectRepo('Naciimo-Abdullahi/Adkaar-Flutter-App');
  await inspectRepo('saallax/samafar');
}

run();
