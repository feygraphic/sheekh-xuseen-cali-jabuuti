const fs = require('fs');
const csvPath = 'assets/data/raw_lectures.csv';
const content = fs.readFileSync(csvPath, 'utf8');
const lines = content.split(/\r?\n/).filter(line => line.trim().length > 0);

for (let i = 1; i < lines.length; i++) {
  const parts = lines[i].trim().split(',');
  const cat = parseInt(parts[parts.length - 1].trim(), 10);
  const url = parts.slice(2, parts.length - 1).join(',').trim();
  const u = new URL(url);
  const segs = u.pathname.split('/');
  console.log(`[${i}] (Cat ${cat}) ${decodeURIComponent(segs[segs.length - 1].replace(/\+/g, ' '))}`);
}
