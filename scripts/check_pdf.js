const fs = require('fs');
const path = require('path');

const pdfPath = path.join(__dirname, 'somali_hisnul_muslim.pdf');
const buffer = fs.readFileSync(pdfPath);

console.log('Buffer size:', buffer.length);
const str = buffer.toString('latin1', 0, 50000);
console.log('PDF Header preview:');
console.log(str.substring(0, 1000));

// Check for font and text streams
const hasFonts = str.includes('/Font');
const hasText = str.includes('/Text') || str.includes('BT');
const hasImage = str.includes('/Image') || str.includes('/XObject');
console.log({ hasFonts, hasText, hasImage });
