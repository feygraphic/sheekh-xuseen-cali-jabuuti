const fs = require('fs');
const path = require('path');

const adhkarDir = path.join(__dirname, '..', 'assets', 'data', 'adhkar');
const files = [
  'morning.json', 'evening.json', 'after_salah.json', 'market.json',
  'sleeping.json', 'ruqyah.json', 'protection.json', 'forgiveness.json',
  'travel.json', 'eating.json', 'home.json', 'mosque.json', 'general_duas.json'
];

let all = [];
for (const f of files) {
  const p = path.join(adhkarDir, f);
  if (fs.existsSync(p)) {
    const list = JSON.parse(fs.readFileSync(p, 'utf8'));
    console.log(`Loaded ${f}: ${list.length} items`);
    all = all.concat(list);
  } else {
    console.error(`Missing file: ${f}`);
  }
}

const targetPath = path.join(adhkarDir, 'adhkar.json');
fs.writeFileSync(targetPath, JSON.stringify(all, null, 2), 'utf8');
console.log(`Successfully merged ${all.length} duas into ${targetPath}`);
