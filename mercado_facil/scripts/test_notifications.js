// Script para testar notificações FCM via API
// Execute: node test_notifications.js

const https = require('https');

// Configurações do projeto
const PROJECT_CONFIG = {
  projectId: 'mercadofacilweb',
  serverKey: 'SUBSTITUA_PELA_SERVER_KEY_DO_FIREBASE_CONSOLE', // Obter do Firebase Console
  messagingSenderId: '10443024714'
};

// Função para enviar notificação
function sendNotification(token, title, body, data = {}) {
  const payload = {
    to: token,
    notification: {
      title: title,
      body: body,
      icon: '/icons/icon-192x192.png',
      badge: '/icons/icon-192x192.png',
      click_action: 'FLUTTER_NOTIFICATION_CLICK'
    },
    data: {
      ...data,
      click_action: 'FLUTTER_NOTIFICATION_CLICK'
    },
    android: {
      priority: 'high',
      notification: {
        channel_id: 'high_importance_channel',
        sound: 'default'
      }
    },
    webpush: {
      headers: {
        Urgency: 'high'
      },
      notification: {
        icon: '/icons/icon-192x192.png',
        badge: '/icons/icon-192x192.png',
        requireInteraction: true
      }
    }
  };

  const postData = JSON.stringify(payload);

  const options = {
    hostname: 'fcm.googleapis.com',
    port: 443,
    path: '/fcm/send',
    method: 'POST',
    headers: {
      'Authorization': `key=${PROJECT_CONFIG.serverKey}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  const req = https.request(options, (res) => {
    console.log(`Status: ${res.statusCode}`);
    console.log(`Headers: ${JSON.stringify(res.headers)}`);
    
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
      console.log(`Response: ${chunk}`);
    });
  });

  req.on('error', (e) => {
    console.error(`Erro: ${e.message}`);
  });

  req.write(postData);
  req.end();
}

// Função para enviar para tópico
function sendToTopic(topic, title, body, data = {}) {
  const payload = {
    to: `/topics/${topic}`,
    notification: {
      title: title,
      body: body,
      icon: '/icons/icon-192x192.png'
    },
    data: data
  };

  const postData = JSON.stringify(payload);

  const options = {
    hostname: 'fcm.googleapis.com',
    port: 443,
    path: '/fcm/send',
    method: 'POST',
    headers: {
      'Authorization': `key=${PROJECT_CONFIG.serverKey}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  const req = https.request(options, (res) => {
    console.log(`Status: ${res.statusCode}`);
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
      console.log(`Response: ${chunk}`);
    });
  });

  req.on('error', (e) => {
    console.error(`Erro: ${e.message}`);
  });

  req.write(postData);
  req.end();
}

// Exemplos de uso
if (require.main === module) {
  console.log('🔥 Script de Teste FCM - Mercado Fácil');
  console.log('=====================================');
  
  // Verificar se a server key foi configurada
  if (PROJECT_CONFIG.serverKey === 'SUBSTITUA_PELA_SERVER_KEY_DO_FIREBASE_CONSOLE') {
    console.error('❌ ERRO: Configure a SERVER_KEY no arquivo!');
    console.log('1. Acesse: https://console.firebase.google.com/project/mercadofacilweb/settings/cloudmessaging');
    console.log('2. Copie a "Server key"');
    console.log('3. Substitua no arquivo test_notifications.js');
    process.exit(1);
  }
  
  // Exemplo de token (substitua pelo token real do dispositivo)
  const EXAMPLE_TOKEN = 'SUBSTITUA_PELO_TOKEN_DO_DISPOSITIVO';
  
  if (process.argv[2] === 'token' && process.argv[3]) {
    // Enviar para token específico
    console.log('📱 Enviando notificação para token específico...');
    sendNotification(
      process.argv[3],
      '🛒 Mercado Fácil',
      'Teste de notificação FCM!',
      { type: 'test', timestamp: Date.now().toString() }
    );
  } else if (process.argv[2] === 'topic' && process.argv[3]) {
    // Enviar para tópico
    console.log(`📢 Enviando notificação para tópico: ${process.argv[3]}`);
    sendToTopic(
      process.argv[3],
      '🛒 Mercado Fácil',
      `Notificação para o tópico ${process.argv[3]}`,
      { type: 'topic', topic: process.argv[3] }
    );
  } else {
    console.log('📖 Como usar:');
    console.log('  node test_notifications.js token <FCM_TOKEN>');
    console.log('  node test_notifications.js topic <TOPIC_NAME>');
    console.log('');
    console.log('📝 Exemplos:');
    console.log('  node test_notifications.js token dGhpc19pc19hX3Rva2Vu...');
    console.log('  node test_notifications.js topic promocoes');
    console.log('  node test_notifications.js topic pedidos');
  }
}

module.exports = { sendNotification, sendToTopic };