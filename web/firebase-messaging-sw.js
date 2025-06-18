importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in your messagingSenderId.
firebase.initializeApp({
  apiKey: "AIzaSyA7rn5E1VYu5iQxjKuF_HLWKFkRZHgO0HE",
  authDomain: "genprd-9675b.firebaseapp.com",
  projectId: "genprd-9675b",
  storageBucket: "genprd-9675b.firebasestorage.app",
  messagingSenderId: "224793841397",
  appId: "1:224793841397:android:bfb71a69f76bc74aa1ffbc"
});

// Retrieve an instance of Firebase Messaging so that it can handle background messages.
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
