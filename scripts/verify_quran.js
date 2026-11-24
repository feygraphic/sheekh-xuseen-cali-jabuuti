const fs = require('fs');
const path = require('path');

const quranPath = path.join(__dirname, '..', 'assets', 'data', 'quran');
const completeFile = path.join(quranPath, 'quran_complete.json');

const data = JSON.parse(fs.readFileSync(completeFile, 'utf8'));

console.log(`Verified Surahs count: ${data.length}`);
let totalAyahs = 0;
let missingTexts = 0;
let missingTranslations = 0;

for (const surah of data) {
  totalAyahs += surah.ayahs.length;
  for (const a of surah.ayahs) {
    if (!a.arabic_text || a.arabic_text.trim().length === 0) {
      missingTexts++;
    }
    if (!a.translation || a.translation.trim().length === 0) {
      missingTranslations++;
    }
  }
}

console.log(`Verified Total Ayahs: ${totalAyahs}`);
console.log(`Missing Arabic texts: ${missingTexts}`);
console.log(`Missing Somali translations: ${missingTranslations}`);

// Also check individual files existence 1 to 114
let filesCount = 0;
for (let i = 1; i <= 114; i++) {
  const f = path.join(quranPath, `surah_${i}.json`);
  if (fs.existsSync(f)) filesCount++;
}
console.log(`Individual surah files verified: ${filesCount} / 114`);
