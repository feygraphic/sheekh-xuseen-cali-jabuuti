const fs = require('fs');
const csvPath = 'assets/data/raw_lectures.csv';
const content = fs.readFileSync(csvPath, 'utf8');
const lines = content.split(/\r?\n/).filter(line => line.trim().length > 0);

for (let i = 1; i <= Math.min(25, lines.length - 1); i++) {
  const parts = lines[i].trim().split(',');
  const url = parts.slice(2, parts.length - 1).join(',').trim();
  const u = new URL(url);
  const segs = u.pathname.split('/');
  console.log(`Line ${i}: ${decodeURIComponent(segs[segs.length - 1])}`);
}
