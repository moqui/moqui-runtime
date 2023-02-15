self.addEventListener('install', (e) => {
    // e.waitUntil(
    //     caches.open('moqui-store').then((cache) => cache.addAll([
    //         '/favicon.ico'
    //     ])),
    // );
});

self.addEventListener('fetch', (e) => {
    // console.log(e.request.url);
    // e.respondWith(
    //     caches.match(e.request).then((response) => response || fetch(e.request)),
    // );
});