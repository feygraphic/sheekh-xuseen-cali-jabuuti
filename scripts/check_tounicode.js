const fs = require('fs');
const path = require('path');

const buffer = fs.readFileSync(path.join(__dirname, 'so_Xisnul_Muslim.pdf'));
const text = buffer.toString('latin1');

const toUnicodeIndices = [];
let idx = 0;
while ((idx = text.indexOf('/ToUnicode', idx)) !== -1) {
  toUnicodeIndices.push(idx);
  idx += 10;
}
console.log('ToUnicode found count:', toUnicodeIndices.length);
