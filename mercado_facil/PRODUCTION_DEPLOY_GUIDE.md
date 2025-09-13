# Guia de Deploy para Produção - Mercado Fácil

## 📋 Checklist de Deploy

### 1. 🔑 Configuração das Chaves Reais no Arquivo .env

#### Onde obter as chaves:

**Firebase:**
- Acesse o [Firebase Console](https://console.firebase.google.com/)
- Selecione seu projeto
- Vá em "Configurações do projeto" (ícone de engrenagem)
- Na aba "Geral", role até "Seus aplicativos"
- Clique em "Configuração" do seu app
- Copie as chaves de configuração

**Chaves específicas necessárias:**
```env
# Firebase Configuration
FIREBASE_API_KEY=sua_api_key_aqui
FIREBASE_AUTH_DOMAIN=seu_projeto.firebaseapp.com
FIREBASE_PROJECT_ID=seu_projeto_id
FIREBASE_STORAGE_BUCKET=seu_projeto.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef123456

# App Check (obter no Firebase Console > App Check)
FIREBASE_APP_CHECK_DEBUG_TOKEN=debug_token_para_desenvolvimento
FIREBASE_RECAPTCHA_SITE_KEY=sua_recaptcha_site_key

# Ambiente
ENVIRONMENT=production
DEBUG_MODE=false

# API URLs
API_BASE_URL=https://sua-api-producao.com
API_TIMEOUT=30000

# Cache
CACHE_DURATION=3600000
MAX_CACHE_SIZE=104857600
```

#### Como obter chave do reCAPTCHA:
1. Acesse [Google reCAPTCHA](https://www.google.com/recaptcha/admin)
2. Clique em "+" para criar um novo site
3. Escolha "reCAPTCHA v3"
4. Adicione seu domínio
5. Copie a "Chave do site"

### 2. 🚀 Deploy das Regras do Firestore

```bash
# Instalar Firebase CLI (se não tiver)
npm install -g firebase-tools

# Fazer login
firebase login

# Verificar projeto atual
firebase projects:list

# Selecionar projeto (se necessário)
firebase use seu-projeto-id

# Deploy apenas das regras do Firestore
firebase deploy --only firestore:rules

# Verificar se as regras foram aplicadas
firebase firestore:rules:get
```

### 3. 🛡️ Configurar App Check no Firebase Console

#### Para Android:
1. No Firebase Console, vá para "App Check"
2. Clique em "Registrar" para seu app Android
3. Escolha "Play Integrity API" como provider
4. Configure o SHA-256 do seu certificado de produção

#### Para iOS:
1. Registre seu app iOS no App Check
2. Escolha "App Attest" como provider
3. Configure o Team ID e Bundle ID

#### Para Web:
1. Registre seu app Web no App Check
2. Escolha "reCAPTCHA v3" como provider
3. Use a chave do site obtida anteriormente

### 4. 🏗️ Build com Variáveis de Ambiente

#### Para Android:
```bash
# Build de produção com variáveis de ambiente
flutter build apk --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=FIREBASE_API_KEY=sua_api_key \
  --dart-define=FIREBASE_PROJECT_ID=seu_projeto_id \
  --dart-define=DEBUG_MODE=false

# Ou para App Bundle (recomendado para Play Store)
flutter build appbundle --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=FIREBASE_API_KEY=sua_api_key \
  --dart-define=FIREBASE_PROJECT_ID=seu_projeto_id \
  --dart-define=DEBUG_MODE=false
```

#### Para iOS:
```bash
flutter build ios --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=FIREBASE_API_KEY=sua_api_key \
  --dart-define=FIREBASE_PROJECT_ID=seu_projeto_id \
  --dart-define=DEBUG_MODE=false
```

#### Para Web:
```bash
flutter build web --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=FIREBASE_API_KEY=sua_api_key \
  --dart-define=FIREBASE_PROJECT_ID=seu_projeto_id \
  --dart-define=DEBUG_MODE=false
```

## 🔧 Configurações Adicionais

### Atualizar environment_config.dart

Certifique-se de que o arquivo `lib/core/config/environment_config.dart` está lendo as variáveis corretamente:

```dart
class EnvironmentConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  
  // ... outras configurações
}
```

### Script de Build Automatizado

Crie um script `scripts/build_production.sh`:

```bash
#!/bin/bash

# Carregar variáveis do .env
source .env

# Build para Android
echo "Building for Android..."
flutter build appbundle --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=DEBUG_MODE=$DEBUG_MODE

echo "Build completed! APK/AAB available in build/app/outputs/"
```

## ✅ Verificações Pós-Deploy

1. **Teste o App Check:**
   - Verifique no Firebase Console se as requisições estão sendo validadas
   - Monitore logs de erro

2. **Teste as Regras do Firestore:**
   - Verifique se apenas usuários autenticados podem acessar dados
   - Teste operações de leitura/escrita

3. **Monitoramento:**
   - Configure alertas no Firebase Console
   - Monitore performance e crashes

4. **Backup:**
   - Configure backup automático do Firestore
   - Documente processo de rollback

## 🚨 Troubleshooting

### Erro de App Check:
- Verifique se o provider está configurado corretamente
- Confirme se as chaves estão corretas
- Para debug, use tokens de debug temporários

### Erro de Regras do Firestore:
- Teste regras no simulador do Firebase Console
- Verifique logs de segurança
- Confirme autenticação do usuário

### Erro de Build:
- Verifique se todas as variáveis estão definidas
- Confirme sintaxe do comando dart-define
- Limpe cache: `flutter clean && flutter pub get`

## 📞 Suporte

Para problemas específicos:
- [Documentação Firebase](https://firebase.google.com/docs)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Support](https://firebase.google.com/support)