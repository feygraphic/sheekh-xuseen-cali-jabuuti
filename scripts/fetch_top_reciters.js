const https = require('https');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return get(res.headers.location).then(resolve).catch(reject);
      }
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    }).on('error', reject);
  });
}

async function run() {
  const [arRes, engRes] = await Promise.all([
    get('https://www.mp3quran.net/api/v3/reciters?language=ar'),
    get('https://www.mp3quran.net/api/v3/reciters?language=eng')
  ]);

  const arReciters = JSON.parse(arRes.data).reciters;
  const engReciters = JSON.parse(engRes.data).reciters;

  const engMap = new Map();
  engReciters.forEach(r => engMap.set(r.id, r.name));

  const targetNames = [
    'العفاسي', 'المعيقلي', 'عبد الباسط', 'الغامدي', 'الشاطري',
    'الحصري', 'المنشاوي', 'الشريم', 'السديس', 'الدوسري',
    'علي جابر', 'العجمي', 'فارس عباد', 'ناصر القطامي', 'إدريس أبكر'
  ];

  const matched = [];
  arReciters.forEach(r => {
    const isMatch = targetNames.some(t => r.name.includes(t));
    if (isMatch && r.moshaf && r.moshaf.length > 0) {
      // Find a moshaf with 114 surahs, preferably Hafs
      const m114 = r.moshaf.find(m => m.surah_total === 114 && (m.moshaf_type === 1 || m.name.includes('حفص') || m.name.includes('مرتل'))) || r.moshaf.find(m => m.surah_total === 114) || r.moshaf[0];
      if (m114 && m114.server) {
        matched.push({
          id: r.id,
          nameAr: r.name,
          nameEn: engMap.get(r.id) || r.name,
          server: m114.server,
          surahTotal: m114.surah_total,
          moshafName: m114.name
        });
      }
    }
  });

  console.log(`Found ${matched.length} popular reciters:`);
  console.log(JSON.stringify(matched, null, 2));
}

run();
