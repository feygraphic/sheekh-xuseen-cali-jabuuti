const fs = require('fs');
const path = require('path');

const adhkarJsonPath = path.join(__dirname, '..', 'assets', 'data', 'adhkar', 'adhkar.json');
const data = JSON.parse(fs.readFileSync(adhkarJsonPath, 'utf8'));

const categories = [
  'Adkaarta Subaxda',
  'Adkaarta Galabta',
  'Salaadda Kadib',
  'Ducada Suuqa',
  'Hurdada & Soo Toosidda',
  'Ruqyah Shariah',
  'Ilaalinta & Xijaabka',
  'Dambi-dhaaf & Toobad',
  'Adkaarta Safarka',
  'Cuntada & Cabitaanka',
  'Gelidda & Bixidda Guriga',
  'Adkaarta Masaajidka',
  'Ducooyin Guud oo Muhiim ah'
];

function escapeDart(str) {
  if (!str) return 'null';
  return `'${str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '\\n').replace(/\$/g, '\\$')}'`;
}

let code = `// AUTO-GENERATED - DO NOT MODIFY DIRECTLY
// Generated from assets/data/adhkar/adhkar.json
import '../models/adkhar_model.dart';

class AdhkarData {
  static const List<String> categories = [
${categories.map(c => `    '${c}',`).join('\n')}
  ];

  static final List<AdkharModel> allAdhkar = [
`;

for (const item of data) {
  code += `    AdkharModel(
      id: ${escapeDart(item.id)},
      categoryId: ${escapeDart(item.categoryId)},
      category: ${escapeDart(item.category)},
      title: ${escapeDart(item.title)},
      arabicTitle: ${escapeDart(item.arabicTitle)},
      arabicText: ${escapeDart(item.arabicText)},
      somaliTranslation: ${escapeDart(item.somaliTranslation)},
      transliteration: ${escapeDart(item.transliteration)},
      reference: ${escapeDart(item.reference)},
      authenticity: ${escapeDart(item.authenticity || 'Saxiix')},
      targetCount: ${item.targetCount || 1},
      currentCount: 0,
      isCompleted: false,
      audioUrl: ${escapeDart(item.audioUrl)},
      isLocalAudio: ${item.isLocalAudio ? 'true' : 'false'},
      virtue: ${escapeDart(item.virtue)},
    ),
`;
}

code += `  ];
}
`;

const outputPath = path.join(__dirname, '..', 'lib', 'data', 'adhkar_data.dart');
fs.writeFileSync(outputPath, code, 'utf8');
console.log(`Updated adhkar_data.dart with ${data.length} items`);
