const https = require('https');
const fs = require('fs');
const path = require('path');

const url = 'https://hisnulmuslim.org/hisnul-muslim/somali/';

https.get(url, (res) => {
  let raw = '';
  res.on('data', chunk => raw += chunk);
  res.on('end', () => {
    fs.writeFileSync(path.join(__dirname, 'hisnulmuslim_somali.html'), raw, 'utf8');
    console.log('Saved hisnulmuslim_somali.html, length:', raw.length);
    
    // Check for links
    const matches = raw.match(/<a[^>]+href="([^"]+)"[^>]*>([^<]+)<\/a>/g) || [];
    console.log('Found links count:', matches.length);
    for (let i = 0; i < Math.min(25, matches.length); i++) {
      console.log('Link:', matches[i]);
    }
  });
});
