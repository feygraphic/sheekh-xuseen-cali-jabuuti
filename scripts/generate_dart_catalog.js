const fs = require('fs');

const raw = fs.readFileSync('assets/data/lectures.json', 'utf8');
const list = JSON.parse(raw);

let dartCode = `// AUTO-GENERATED - ALL 131 SHEEKH XUSEEN CALI JABUUTI LECTURES
import '../models/lecture_model.dart';

const List<LectureModel> allSheekhXuseenLectures = [
`;

list.forEach((l) => {
  const safeArabic = l.arabicTitle.replace(/'/g, "\\'");
  const safeSomali = l.somaliTitle.replace(/'/g, "\\'");
  const safeSeries = l.seriesName.replace(/'/g, "\\'");
  const safeCategory = l.category.replace(/'/g, "\\'");
  const safeUrl = l.audioUrl.replace(/'/g, "\\'");
  const safeDesc = l.description.replace(/'/g, "\\'");
  const mins = Math.floor(l.durationMs / 60000);

  dartCode += `  LectureModel(
    id: '${l.id}',
    trackNumber: ${l.trackNumber},
    arabicTitle: '${safeArabic}',
    somaliTitle: '${safeSomali}',
    seriesNumber: ${l.seriesNumber},
    seriesName: '${safeSeries}',
    category: '${safeCategory}',
    duration: Duration(minutes: ${mins}),
    audioUrl: '${safeUrl}',
    isLocalAsset: false,
    sheikhName: 'Sheekh Xuseen Cali Jabuuti (Xafidahullaah)',
    listenCount: '${l.listenCount}',
    imageUrl: '${l.imageUrl}',
    description: '${safeDesc}',
  ),
`;
});

dartCode += `];\n`;

fs.writeFileSync('lib/data/lectures_catalog.dart', dartCode, 'utf8');
console.log('Successfully generated lib/data/lectures_catalog.dart with', list.length, 'lectures!');
