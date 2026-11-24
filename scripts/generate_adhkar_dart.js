const fs = require('fs');
const path = require('path');

const jsonPath = path.join(__dirname, '..', 'assets', 'data', 'adhkar', 'adhkar.json');
const adhkarList = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

function escapeDart(str) {
  if (!str) return "''";
  return "'" + str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '\\n') + "'";
}

let code = `// AUTO-GENERATED - DO NOT MODIFY DIRECTLY
// Generated from assets/data/adhkar/adhkar.json
import '../models/adkhar_model.dart';

class AdhkarData {
  static const List<String> categories = [
    'Adkaarta Subaxda',
    'Adkaarta Galabta',
    'Salaadda Kadib',
    'Adkaarta Hurdada',
    'Adkaarta Soo Toosidda',
    'Gelidda & Ka-bixidda Guriga',
    'Gelidda & Ka-bixidda Masaajidka',
    'Adkaarta Safarka',
    'Cuntada & Cabitaanka',
    'Adkaar Kale oo Maalinle ah',
  ];

  static final List<AdkharModel> allAdhkar = [
`;

adhkarList.forEach(item => {
  code += `    AdkharModel(
      id: ${escapeDart(item.id)},
      category: ${escapeDart(item.category)},
      title: ${escapeDart(item.title)},
      arabicText: ${escapeDart(item.arabicText)},
      somaliTranslation: ${escapeDart(item.somaliTranslation)},
      reference: ${escapeDart(item.reference)},
      authenticity: ${escapeDart(item.authenticity || 'Saxiix')},
      targetCount: ${item.targetCount},
      currentCount: 0,
      isCompleted: false,
      audioUrl: ${item.audioUrl ? escapeDart(item.audioUrl) : 'null'},
      isLocalAudio: false,
    ),
`;
});

code += `  ];

  static List<AdkharModel> getByCategory(String category) {
    if (category == 'Dhammaan') return allAdhkar;
    return allAdhkar.where((a) => a.category == category).toList();
  }
}
`;

const outputPath = path.join(__dirname, '..', 'lib', 'data', 'adhkar_data.dart');
fs.writeFileSync(outputPath, code, 'utf8');
console.log(`Generated ${outputPath} with ${adhkarList.length} items!`);
