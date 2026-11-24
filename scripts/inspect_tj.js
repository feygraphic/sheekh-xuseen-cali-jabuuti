const fs = require('fs');
const path = require('path');

const text = fs.readFileSync(path.join(__dirname, 'extracted_pdf_streams.txt'), 'utf8');

// Find TJ lines
const lines = text.split('\n');
const tjLines = lines.filter(l => l.includes('TJ') || l.includes('Tj'));
console.log('TJ/Tj lines count:', tjLines.length);
console.log('Sample lines:');
console.log(tjLines.slice(0, 30).join('\n'));
