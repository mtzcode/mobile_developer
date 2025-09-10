# 🔥 Guia de Configuração do Firebase Console

## 📋 Informações do Projeto

- **Project ID:** `mercadofacilweb`
- **Project Number:** `10443024714`
- **Messaging Sender ID:** `10443024714`
- **Package Name (Android):** `com.mtzcode.mercado_facil`

## 🚀 Etapa 1: Configurar Firebase Console

### 1.1 Acessar o Firebase Console
1. Acesse: https://console.firebase.google.com/
2. Selecione o projeto: **mercadofacilweb**
3. No menu lateral, clique em **Cloud Messaging**

### 1.2 Configurar Android
1. Na seção **Android apps**, verifique se o app está listado:
   - **App ID:** `1:10443024714:android:bdd13bdf5a937ea8a439b3`
   - **Package name:** `com.mtzcode.mercado_facil`

2. **Obter Server Key:**
   - Vá para **Project Settings** (ícone de engrenagem)
   - Aba **Cloud Messaging**
   - Copie a **Server key** (será usada no backend)

### 1.3 Configurar Web
1. Na seção **Web apps**, verifique se o app está listado:
   - **App ID:** `1:10443024714:web:2f25bdbfbc090c14a439b3`

2. **Configurar Web Push:**
   - Vá para **Project Settings** > **Cloud Messaging**
   - Na seção **Web configuration**
   - Gere um **Web Push certificate** (VAPID key)
   - Copie a **Key pair** gerada

## 🧪 Etapa 2: Testar Notificações

### 2.1 Enviar Notificação de Teste
1. No Firebase Console, vá para **Cloud Messaging**
2. Clique em **Send your first message**
3. Preencha:
   - **Notification title:** "Teste FCM"
   - **Notification text:** "Notificação de teste do Mercado Fácil"
4. Em **Target**, selecione:
   - **App:** Escolha o app Android ou Web
   - **User segment:** All users
5. Clique em **Review** e depois **Publish**

### 2.2 Testar com Token Específico
1. Execute o app e copie o FCM token do console
2. No Firebase Console, em **Cloud Messaging**
3. Clique em **Send test message**
4. Cole o **FCM registration token**
5. Envie a notificação

## 🔧 Etapa 3: Configurações Avançadas

### 3.1 Configurar Tópicos
```javascript
// Exemplo de inscrição em tópicos
FirebaseMessaging.instance.subscribeToTopic('promocoes');
FirebaseMessaging.instance.subscribeToTopic('pedidos');
```

### 3.2 Configurar Condições
- Enviar para usuários que se inscreveram em tópicos específicos
- Segmentar por versão do app, idioma, etc.

## 📱 Etapa 4: Testar em Dispositivos

### 4.1 Android
1. Compile o app para Android: `flutter build apk`
2. Instale no dispositivo
3. Teste notificações em foreground e background

### 4.2 Web
1. Execute: `flutter build web`
2. Teste em diferentes navegadores
3. Verifique permissões de notificação

## 🔑 Informações Importantes

### Chaves do Projeto
- **Web API Key:** `AIzaSyAf3OruYIPCu_AgzAKOdOa_b-gySSEL7RQ`
- **Android API Key:** `AIzaSyDnr_TEHXiLbYSz8RXJcbdR2ao9DbwCuk4`
- **Auth Domain:** `mercadofacilweb.firebaseapp.com`
- **Storage Bucket:** `mercadofacilweb.firebasestorage.app`

### URLs Úteis
- **Firebase Console:** https://console.firebase.google.com/project/mercadofacilweb
- **Cloud Messaging:** https://console.firebase.google.com/project/mercadofacilweb/messaging
- **Project Settings:** https://console.firebase.google.com/project/mercadofacilweb/settings/general

## ⚠️ Próximos Passos

1. ✅ Configurar Firebase Console
2. ⏳ Testar notificações
3. ⏳ Implementar backend APIs
4. ⏳ Personalizar UI
5. ⏳ Testar em dispositivos reais

---

**Nota:** Mantenha as chaves do servidor seguras e nunca as exponha no código cliente.