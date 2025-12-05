const CACHE_NAME = "unsoed-sipiru-v1";
const urlsToCache = [
  "/", 
  "/static/unsoed.css",
  "/static/unsoed.js",
  "/static/logo.webp"
];

// Install SW
self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))
  );
});

// Fetch handler
self.addEventListener("fetch", event => {
  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request);
    })
  );
});
