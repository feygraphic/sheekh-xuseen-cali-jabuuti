const https = require('https');
const fs = require('fs');
const path = require('path');

const OUTPUT_DIR = path.join(__dirname, '..', 'assets', 'data', 'quran');

if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

// Standard verse counts for 114 Surahs (sum = 6236)
const VERSE_COUNTS = [
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109,
  123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
  112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
  34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
  54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
  60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
  14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
  28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
  29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
  15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
  11, 8, 3, 9, 5, 4, 7, 3, 6, 3,
  5, 4, 5, 6
];

const totalExpectedVerses = VERSE_COUNTS.reduce((a, b) => a + b, 0);
console.log(`Total expected verses across 114 surahs: ${totalExpectedVerses}`);

function fetchSurah(suraNumber, attempt = 1) {
  return new Promise((resolve, reject) => {
    const url = `https://quranenc.com/api/v1/translation/sura/somali_yacob/${suraNumber}`;
    https.get(url, (res) => {
      if (res.statusCode !== 200) {
        if (attempt < 5) {
          console.log(`Retrying surah ${suraNumber} (status ${res.statusCode}), attempt ${attempt + 1}...`);
          setTimeout(() => {
            fetchSurah(suraNumber, attempt + 1).then(resolve).catch(reject);
          }, 1500 * attempt);
          return;
        }
        return reject(new Error(`HTTP ${res.statusCode} for Surah ${suraNumber}`));
      }

      let raw = '';
      res.on('data', chunk => raw += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(raw);
          if (!parsed.result || !Array.isArray(parsed.result)) {
            throw new Error(`Invalid response structure for Surah ${suraNumber}`);
          }
          resolve(parsed.result);
        } catch (e) {
          if (attempt < 5) {
            console.log(`JSON parse error on surah ${suraNumber}, retrying...`);
            setTimeout(() => {
              fetchSurah(suraNumber, attempt + 1).then(resolve).catch(reject);
            }, 1500 * attempt);
          } else {
            reject(e);
          }
        }
      });
    }).on('error', (err) => {
      if (attempt < 5) {
        console.log(`Network error on surah ${suraNumber} (${err.message}), retrying...`);
        setTimeout(() => {
          fetchSurah(suraNumber, attempt + 1).then(resolve).catch(reject);
        }, 1500 * attempt);
      } else {
        reject(err);
      }
    });
  });
}

async function run() {
  const completeQuran = [];
  let totalAyahsDownloaded = 0;
  const startTime = Date.now();

  for (let s = 1; s <= 114; s++) {
    const expectedCount = VERSE_COUNTS[s - 1];
    process.stdout.write(`Downloading Surah ${s}/114 (expected ${expectedCount} ayahs)... `);
    
    try {
      const ayahs = await fetchSurah(s);
      
      if (ayahs.length !== expectedCount) {
        console.warn(`\n[WARNING] Surah ${s} returned ${ayahs.length} verses, expected ${expectedCount}`);
      }

      // Structure clean surah object
      const surahData = {
        surah_number: s,
        ayahs_count: ayahs.length,
        ayahs: ayahs.map((a, index) => {
          const ayahNum = parseInt(a.aya, 10) || (index + 1);
          return {
            id: parseInt(a.id, 10),
            surah: s,
            ayah: ayahNum,
            arabic_text: a.arabic_text ? a.arabic_text.trim() : '',
            translation: a.translation ? a.translation.trim() : '',
            footnotes: a.footnotes ? a.footnotes.trim() : ''
          };
        })
      };

      // Save individual surah JSON
      const surahFilePath = path.join(OUTPUT_DIR, `surah_${s}.json`);
      fs.writeFileSync(surahFilePath, JSON.stringify(surahData, null, 2), 'utf8');

      completeQuran.push(surahData);
      totalAyahsDownloaded += ayahs.length;
      console.log(`OK (${ayahs.length} ayahs)`);

      // Gentle pause to avoid rate limiting
      await new Promise(r => setTimeout(r, 120));
    } catch (err) {
      console.error(`\n[ERROR] Failed to fetch Surah ${s}:`, err.message);
      process.exit(1);
    }
  }

  // Save complete consolidated Quran JSON
  const completeFilePath = path.join(OUTPUT_DIR, 'quran_complete.json');
  fs.writeFileSync(completeFilePath, JSON.stringify(completeQuran), 'utf8');

  // Save source attribution
  const attribution = {
    sources: [
      {
        name: "QuranEnc.com",
        description: "Free translation of the meanings of the Noble Quran into Somali",
        translator: "Mahmud Muhammad Abduh (Yacob)",
        identifier: "somali_yacob",
        website: "https://quranenc.com",
        api: "https://quranenc.com/api/v1/translation/sura/somali_yacob/{sura_number}",
        license: "Free for non-commercial and educational distribution for the dissemination of Islamic knowledge."
      },
      {
        name: "Tanzil Project",
        description: "Verified Uthmani Quranic Arabic Script with precise vocalization and diacritics",
        website: "https://tanzil.net",
        license: "Creative Commons Attribution 3.0 Unported License"
      }
    ],
    total_surahs: 114,
    total_ayahs: totalAyahsDownloaded,
    download_date: new Date().toISOString()
  };

  fs.writeFileSync(path.join(OUTPUT_DIR, 'attribution.json'), JSON.stringify(attribution, null, 2), 'utf8');

  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
  console.log('========================================================');
  console.log(`DOWNLOAD COMPLETE in ${elapsed}s`);
  console.log(`Total Surahs: ${completeQuran.length} / 114`);
  console.log(`Total Ayahs: ${totalAyahsDownloaded} / 6236`);
  console.log(`Saved to: ${OUTPUT_DIR}`);
  console.log('========================================================');
}

run();
