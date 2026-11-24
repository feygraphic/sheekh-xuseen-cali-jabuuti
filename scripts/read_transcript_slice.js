const fs = require('fs');
const readline = require('readline');
const rl = readline.createInterface({
  input: fs.createReadStream('C:/Users/user/.gemini/antigravity/brain/f81e49ce-2df7-402b-a8f2-69fa7848026e/.system_generated/logs/transcript.jsonl')
});
rl.on('line', line => {
  const j = JSON.parse(line);
  if (j.step_index >= 105 && j.step_index <= 120) {
    console.log(j.step_index, j.type, j.source, j.content ? j.content.substring(0, 150) : '');
  }
});
