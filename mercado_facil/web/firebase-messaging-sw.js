// Firebase Cloud Messaging Service Worker
// Este arquivo é necessário para receber notificações em background no web

importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// Configuração do Firebase (deve corresponder ao firebase_options.dart)
firebase.initializeApp({
  apiKey: "AIzaSyAf3OruYIPCu_AgzAKOdOa_b-gySSEL7RQ",
  authDomain: "mercadofacilweb.firebaseapp.com",
  projectId: "mercadofacilweb",
  storageBucket: "mercadofacilweb.firebasestorage.app",
  messagingSenderId: "10443024714",
  appId: "1:10443024714:web:2f25bdbfbc090c14a439b3"
});

// Inicializa o Firebase Messaging
const messaging = firebase.messaging();

// Manipula mensagens em background
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  // Customiza a notificação
  const notificationTitle = payload.notification?.title || 'Mercado Fácil';
  const notificationOptions = {
    body: payload.notification?.body || 'Nova notificação',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'mercado-facil-notification',
    requireInteraction: true,
    actions: [
      {
        action: 'open',
        title: 'Abrir App'
      },
      {
        action: 'close',
        title: 'Fechar'
      }
    ]
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Manipula cliques na notificação
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Notification click received.');
  
  event.notification.close();
  
  if (event.action === 'open') {
    // Abre ou foca na janela do app
    event.waitUntil(
      clients.matchAll({ type: 'window', includeUncontrolled: true })
        .then(function(clientList) {
          if (clientList.length > 0) {
            return clientList[0].focus();
          }
          return clients.openWindow('/');
        })
    );
  }
});