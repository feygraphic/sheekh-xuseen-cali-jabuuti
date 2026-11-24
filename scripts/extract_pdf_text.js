const fs = require('fs');
const zlib = require('zlib');
const path = require('path');

const buffer = fs.readFileSync(path.join(__dirname, 'so_Xisnul_Muslim.pdf'));
let pos = 0;
let extractedText = '';

while (pos < buffer.length) {
  const streamStart = buffer.indexOf('stream\r\n', pos) !== -1 ? buffer.indexOf('stream\r\n', pos) + 8 : buffer.indexOf('stream\n', pos) + 7;
  if (streamStart === -1 || streamStart < pos) break;
  const streamEnd = buffer.indexOf('endstream', streamStart);
  if (streamEnd === -1) break;

  const chunk = buffer.subarray(streamStart, streamEnd);
  try {
    const uncompressed = zlib.inflateSync(chunk);
    const text = uncompressed.toString('latin1');
    if (text.includes('Tj') || text.includes('TJ')) {
      extractedText += text + '\n';
    }
  } catch (e) {
    // not flate or corrupted chunk, ignore
  }
  pos = streamEnd + 9;
}

console.log('Total extracted stream text length:', extractedText.length);
fs.writeFileSync(path.join(__dirname, 'extracted_pdf_streams.txt'), extractedText);

// Look for readable strings in extracted text
const matches = extractedText.match(/\(([^()]{3,100})\)\s*Tj/g);
console.log('Matches found:', matches ? matches.length : 0);
if (matches) {
  console.log('Sample matches:');
  console.log(matches.slice(100, 120).join('\n'));
}
