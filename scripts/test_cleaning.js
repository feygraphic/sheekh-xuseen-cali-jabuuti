const fs = require('fs');

const csvPath = 'assets/data/raw_lectures.csv';
const content = fs.readFileSync(csvPath, 'utf8');
const lines = content.split(/\r?\n/).filter(line => line.trim().length > 0);

const items = [];
for (let i = 1; i < lines.length; i++) {
  const parts = lines[i].trim().split(',');
  const cat = parseInt(parts[parts.length - 1].trim(), 10);
  const somaliTitle = parts[0].trim();
  const arabicTitle = parts[1].trim();
  const url = parts.slice(2, parts.length - 1).join(',').trim();
  items.push({ index: i, cat, somaliTitle, arabicTitle, url });
}

function cleanSomaliTitle(url, rawTitle, index) {
  let name = '';
  try {
    const u = new URL(url);
    const segs = u.pathname.split('/');
    name = decodeURIComponent(segs[segs.length - 1].replace(/\+/g, ' '));
  } catch (e) {
    name = url;
  }

  // Remove .mp3 extension
  name = name.replace(/\.mp3$/i, '');

  // Remove trailing media source / creator tags
  name = name.replace(/\s*-\s*Mustaqim Media.*$/i, '');
  name = name.replace(/\s*-\s*Qurbe Joog.*$/i, '');
  name = name.replace(/\s*\[\d{4}\].*$/i, '');
  name = name.replace(/\s*\(NURUL-ISLAM\s*STEREO.*$/i, '');
  name = name.replace(/\s*NURUL-ISLAM\s*STEREO.*$/i, '');
  name = name.replace(/\s*\+254\d+.*$/i, '');
  name = name.replace(/\s*\(1\)$/i, '');
  name = name.replace(/\s*\(2\)$/i, '');

  // Remove decorative emojis / symbols
  name = name.replace(/[^\w\s\u0600-\u06FF\u0750-\u077F\-',.!?ﷺ]/g, ' ');

  // Clean speaker name suffixes
  name = name.replace(/\s*[-–—|┇~]\s*(?:Sheekh|Sh\.?|Sh)\s*(?:Xuseen|Xuseyn|Xusen|Cli)?\s*(?:Cali)?\s*(?:Jabuuti|Jabuti)?.*$/i, '');
  name = name.replace(/\s*(?:Sheekh|Sh\.?)\s*(?:Xuseen|Xuseyn|Xusen)\s*(?:Cali)?\s*(?:Jabuuti|Jabuti)?\s*\d{4}.*$/i, '');
  name = name.replace(/\s*(?:Sheekh|Sh\.?)\s*(?:Xuseen|Xuseyn|Xusen)\s*(?:Cali)?\s*(?:Jabuuti|Jabuti)?.*$/i, '');

  // Clean leading numbers like "01 ", "0004", "02=", "03= ", "026"
  name = name.replace(/^\d+[\s=_\-]+/, '');
  name = name.replace(/^=\s*/, '');

  // Remove standalone years at end (e.g., 2022, 2023, 2024, 2025)
  name = name.replace(/\s*\b20\d\d\b\s*$/, '');

  // Normalize spaces
  name = name.replace(/\s+/g, ' ').trim();

  // If name became too short or empty, fallback
  if (name.length < 3) {
    name = `Muxaadaro Qaybta ${index}`;
  }

  // Capitalize properly
  name = name.charAt(0).toUpperCase() + name.slice(1);
  return name;
}

const cleaned = items.map((it, idx) => {
  const somali = cleanSomaliTitle(it.url, it.somaliTitle, idx + 1);
  return {
    index: it.index,
    cat: it.cat,
    somali,
    url: it.url,
  };
});

cleaned.slice(0, 30).forEach(c => {
  console.log(`[#${c.index}] (Cat ${c.cat}) -> ${c.somali}`);
});
