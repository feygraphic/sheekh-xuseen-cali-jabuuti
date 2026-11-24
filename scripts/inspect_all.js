const fs = require('fs');

const csvPath = 'assets/data/raw_lectures.csv';
const content = fs.readFileSync(csvPath, 'utf8');

const lines = content.split(/\r?\n/).filter(line => line.trim().length > 0);
console.log(`Total lines: ${lines.length}`);

const rows = [];
for (let i = 1; i < lines.length; i++) {
  const line = lines[i].trim();
  if (!line) continue;
  const parts = line.split(',');
  const catNum = parseInt(parts[parts.length - 1].trim(), 10);
  const somaliTitle = parts[0].trim();
  const arabicTitle = parts[1].trim();
  const audioUrl = parts.slice(2, parts.length - 1).join(',').trim();
  rows.push({
    index: i,
    somaliTitle,
    arabicTitle,
    audioUrl,
    categoryNumber: catNum,
  });
}

console.log(`Parsed ${rows.length} rows.`);

// Let's examine URLs and extracted titles
rows.forEach((r, idx) => {
  const url = r.audioUrl;
  let filename = '';
  try {
    const u = new URL(url);
    const segs = u.pathname.split('/');
    filename = decodeURIComponent(segs[segs.length - 1].replace(/\+/g, ' '));
  } catch (e) {
    filename = url;
  }
  r.filename = filename;
});

// Print categories and sample titles per category
for (let cat = 1; cat <= 10; cat++) {
  const inCat = rows.filter(r => r.categoryNumber === cat);
  console.log(`\n=== Category ${cat} (${inCat.length} items) ===`);
  inCat.slice(0, 3).forEach(r => {
    console.log(`  [${r.index}] URL filename: "${r.filename}" | Raw Somali: "${r.somaliTitle}" | Raw Arabic: "${r.arabicTitle}"`);
  });
}
