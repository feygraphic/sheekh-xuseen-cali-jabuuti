const fs = require('fs');

const uploadedPath = 'C:/Users/user/.gemini/antigravity/brain/f8c27470-8ff6-462e-aee7-a9bbad43a6fa/.user_uploaded/media_1793951423340_d879b325.csv';
const assetPath = 'assets/data/raw_lectures.csv';

const uploadedContent = fs.readFileSync(uploadedPath, 'utf8');
const assetContent = fs.readFileSync(assetPath, 'utf8');

console.log('Uploaded size:', uploadedContent.length, 'Asset size:', assetContent.length);
console.log('Same content?', uploadedContent === assetContent);

const parseCSV = (text) => {
  const lines = text.split(/\r?\n/).filter(l => l.trim().length > 0);
  const header = lines[0];
  const items = [];
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    // Format: somalititle,arabictitle,audiourl,categorynumber
    // Careful with potential commas
    const parts = line.split(',');
    if (parts.length >= 4) {
      const somalititle = parts[0].trim();
      const arabictitle = parts[1].trim();
      // url might be index 2, or if extra commas
      const categorynumber = parseInt(parts[parts.length - 1].trim(), 10);
      const audiourl = parts.slice(2, parts.length - 1).join(',').trim();
      items.push({ lineIndex: i, somalititle, arabictitle, audiourl, categorynumber, raw: line });
    } else {
      console.log('Strange line:', i, line);
    }
  }
  return items;
};

const items = parseCSV(uploadedContent);
console.log(`Parsed items: ${items.length}`);

// Let's inspect categories
const catCounts = {};
const buckets = {};
const uniqueUrls = new Set();
const duplicateUrls = [];

items.forEach((it, idx) => {
  catCounts[it.categorynumber] = (catCounts[it.categorynumber] || 0) + 1;
  try {
    const u = new URL(it.audiourl);
    buckets[u.hostname] = (buckets[u.hostname] || 0) + 1;
  } catch (e) {
    console.log('Invalid URL at index', idx, it.audiourl);
  }
  if (uniqueUrls.has(it.audiourl)) {
    duplicateUrls.push(it.audiourl);
  } else {
    uniqueUrls.add(it.audiourl);
  }
});

console.log('Category distribution:', catCounts);
console.log('Buckets distribution:', buckets);
console.log(`Unique URLs: ${uniqueUrls.size}, Duplicate URLs: ${duplicateUrls.length}`);
if (duplicateUrls.length > 0) {
  console.log('Duplicates:', duplicateUrls);
}
