importScripts('https://www.gstatic.com/firebasejs/10.3.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.3.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAzoP9b--fAARxjc8QbG6km5Yuy3Bzrg-k",
  authDomain: "autocaller-196cc.firebaseapp.com",
  projectId: "autocaller-196cc",
  storageBucket: "autocaller-196cc.firebasestorage.app",
  messagingSenderId: "132580101106",
  appId: "1:132580101106:web:46fcaedc08f6f8a82cb96b"
});

const messaging = firebase.messaging();
