// web/firebase-messaging-sw.js
importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js");

// Remplacez ces valeurs par celles de votre projet Firebase
// (Vous les trouverez dans lib/firebase_options.dart)
firebase.initializeApp({
   apiKey: 'AIzaSyBkCXaYxMgr949ifMwzIhQa22Fb3IYOTvk',
    appId: '1:961163650621:web:0d458294724afd13d6ec54',
    messagingSenderId: '961163650621',
    projectId: 'packeasy-8c952',
    authDomain: 'packeasy-8c952.firebaseapp.com',
    storageBucket: 'packeasy-8c952.firebasestorage.app',
    measurementId: 'G-SEBRXLW5LT',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Message reçu en arrière-plan ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});