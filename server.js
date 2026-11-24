const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const PUBLIC_DIR = path.join(__dirname, 'build', 'web');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.mp3': 'audio/mpeg',
  '.wav': 'audio/wav',
  '.ogg': 'audio/ogg',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

const server = http.createServer((req, res) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  // Add CORS and caching headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Audio Proxy for Web Audio / CORS compatibility
  if (req.url.startsWith('/audio-proxy?url=')) {
    const targetUrl = decodeURIComponent(req.url.substring('/audio-proxy?url='.length));
    const https = require('https');
    try {
      const parsed = new URL(targetUrl);
      const headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      };
      if (req.headers.range) {
        headers['Range'] = req.headers.range;
      }

      const proxyReq = https.request(parsed, { method: req.method, headers }, (proxyRes) => {
        const responseHeaders = {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
          'Access-Control-Allow-Headers': '*',
          'Content-Type': proxyRes.headers['content-type'] || 'audio/mpeg',
          'Accept-Ranges': 'bytes',
        };
        if (proxyRes.headers['content-length']) {
          responseHeaders['Content-Length'] = proxyRes.headers['content-length'];
        }
        if (proxyRes.headers['content-range']) {
          responseHeaders['Content-Range'] = proxyRes.headers['content-range'];
        }
        res.writeHead(proxyRes.statusCode, responseHeaders);
        if (req.method === 'HEAD') {
          res.end();
          proxyRes.destroy();
        } else {
          proxyRes.pipe(res);
        }
      });

      proxyReq.on('error', (err) => {
        console.error('Audio proxy error:', err);
        res.writeHead(500, { 'Access-Control-Allow-Origin': '*' });
        res.end('Proxy error: ' + err.message);
      });
      proxyReq.end();
      return;
    } catch (e) {
      res.writeHead(400, { 'Access-Control-Allow-Origin': '*' });
      res.end('Invalid URL');
      return;
    }
  }

  let reqPath = decodeURI(req.url.split('?')[0]);
  if (reqPath === '/' || reqPath === '') {
    reqPath = '/index.html';
  }

  let filePath = path.join(PUBLIC_DIR, reqPath);

  // Normalize path security
  if (!filePath.startsWith(PUBLIC_DIR)) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // Fallback to index.html for SPA routes
      filePath = path.join(PUBLIC_DIR, 'index.html');
      fs.stat(filePath, (err2, stats2) => {
        if (err2 || !stats2.isFile()) {
          res.writeHead(404);
          res.end('Not Found');
          return;
        }
        serveFile(req, res, filePath, stats2);
      });
      return;
    }

    serveFile(req, res, filePath, stats);
  });
});

function serveFile(req, res, filePath, stats) {
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';
  const range = req.headers.range;

  // Range support for audio streaming and seeking
  if (range && ext === '.mp3') {
    const parts = range.replace(/bytes=/, '').split('-');
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : stats.size - 1;
    const chunksize = end - start + 1;

    res.writeHead(206, {
      'Content-Range': `bytes ${start}-${end}/${stats.size}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunksize,
      'Content-Type': contentType,
    });

    const stream = fs.createReadStream(filePath, { start, end });
    stream.pipe(res);
  } else {
    res.writeHead(200, {
      'Content-Length': stats.size,
      'Content-Type': contentType,
      'Accept-Ranges': 'bytes',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    });
    fs.createReadStream(filePath).pipe(res);
  }
}

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});
