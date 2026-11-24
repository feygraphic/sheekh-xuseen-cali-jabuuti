const fs = require('fs');
const path = require('path');

const file = path.join(__dirname, 'hisnulmuslim_somali.html');
const html = fs.readFileSync(file, 'utf8');

// Strip HTML tags and see the text
const text = html.replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
                 .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
                 .replace(/<[^>]+>/g, ' ')
                 .replace(/\s+/g, ' ');

console.log('Text length:', text.length);
console.log('Text sample:');
console.log(text.substring(0, 1500));
