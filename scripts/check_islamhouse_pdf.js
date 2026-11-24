const fs = require('fs');
const path = require('path');

const pdfPath = path.join(__dirname, 'so_Xisnul_Muslim.pdf');
const buffer = fs.readFileSync(pdfPath);

console.log('Buffer size:', buffer.length);
const str = buffer.toString('latin1');
const hasFonts = str.includes('/Font');
const hasBT = str.includes('BT');
const hasTj = str.includes('Tj') || str.includes('TJ');
console.log({ hasFonts, hasBT, hasTj });

// Find some text snippets
const matches = str.match(/\(([^()]{4,50})\)\s*Tj/g);
console.log('Sample text snippets:', matches ? matches.slice(0, 20) : 'None');
