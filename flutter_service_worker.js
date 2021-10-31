'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "a57e1472c761372ab07add13c5de4573",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/NOTICES": "f410ab731d0b80e5b57dcee8ea67c9c2",
"assets/assets/images/parallax-forest-lights.png": "6abd59acb4c8ed72b3eecac698aeb52d",
"assets/assets/images/poison.png": "55650cbb4a4cc01cd68ab5b3af5f032c",
"assets/assets/images/parallax/layers/parallax-forest-lights.png": "6abd59acb4c8ed72b3eecac698aeb52d",
"assets/assets/images/parallax/layers/parallax-forest-back-trees.png": "742fdebdf6977d4443c673ed6be8ef47",
"assets/assets/images/parallax/layers/parallax-forest-middle-trees.png": "953f7a727d7d4725a4b4fee91071d3f2",
"assets/assets/images/parallax/layers/parallax-forest-front-trees.png": "90eeed8bb9545a3dda46c2b04cf44c1b",
"assets/assets/images/parallax-forest-back-trees.png": "742fdebdf6977d4443c673ed6be8ef47",
"assets/assets/images/42.png": "904724c706550fc06c632d5e395c8a44",
"assets/assets/images/cauldron.png": "f0b3e1dfa0797541f80de04318e33af1",
"assets/assets/images/parallax-forest-middle-trees.png": "953f7a727d7d4725a4b4fee91071d3f2",
"assets/assets/images/parallax-forest-front-trees.png": "90eeed8bb9545a3dda46c2b04cf44c1b",
"assets/assets/images/44.png": "57e005a971ac10d7931c50b1801f5ee0",
"assets/assets/images/hatpumpkin.png": "c69b306442867eef4675ae9b68303403",
"assets/assets/images/flame.png": "f910f712d3a1faa6e001faae377aa72e",
"assets/assets/images/pumpkin.png": "bf614988f1bcbd288c0d8c55421f3222",
"assets/assets/audio/GucciGhost.mp3": "a811357c65871c4f6549fd8201b1b6c9",
"assets/assets/audio/sfx/sad.mp3": "6514d8a707ed3b39c1d5d394671d0bc1",
"assets/assets/audio/sfx/happy.mp3": "cc5e98ecceeeb66904c493f84baae4ce",
"assets/assets/audio/sfx/sad.m4a": "91056588bdd908bf91e19dc1847e0b7b",
"assets/assets/audio/sfx/happy2.mp3": "8f04e1975dc166b73758cc9325cc8d95",
"assets/assets/audio/sfx/happy.m4a": "1d32bfdc1eeafa94ec5f62885bcffab2",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.json": "3be36c0893b9b5bd202ac6a6ecbc4ab7",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"main.dart.js": "28aa07e3724287791aa0c31ee7d26b82",
"manifest.json": "2f61ff86a76cf58b42d3f0c66ec15a4e",
"index.html": "c45573612f2d4fa4451ef819c82a93f7",
"/": "c45573612f2d4fa4451ef819c82a93f7"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
