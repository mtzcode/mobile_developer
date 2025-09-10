# 🚀 Guia de Deploy - Mercado Fácil

Este documento fornece instruções detalhadas para fazer deploy do Mercado Fácil em diferentes plataformas.

## 📋 Índice

- [Pré-requisitos](#pré-requisitos)
- [Configuração do Firebase](#configuração-do-firebase)
- [Deploy Android](#deploy-android)
- [Deploy iOS](#deploy-ios)
- [Deploy Web](#deploy-web)
- [Deploy Desktop](#deploy-desktop)
- [CI/CD com GitHub Actions](#cicd-com-github-actions)
- [Monitoramento e Analytics](#monitoramento-e-analytics)
- [Troubleshooting](#troubleshooting)

## ⚙️ Pré-requisitos

### Ferramentas Necessárias

- **Flutter SDK** 3.19.0 ou superior
- **Dart SDK** 3.3.0 ou superior
- **Android Studio** (para Android)
- **Xcode** (para iOS - apenas macOS)
- **Firebase CLI** 12.0.0 ou superior
- **Git** para controle de versão

### Contas Necessárias

- **Google Play Console** (Android)
- **Apple Developer Account** (iOS)
- **Firebase Project**
- **GitHub Account** (para CI/CD)

### Instalação das Ferramentas

```bash
# Instalar Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor

# Instalar Firebase CLI
npm install -g firebase-tools

# Verificar instalação
flutter --version
firebase --version
```

## 🔥 Configuração do Firebase

### 1. Criar Projeto Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Digite o nome: "Mercado Fácil"
4. Ative Google Analytics (recomendado)
5. Escolha conta do Google Analytics

### 2. Configurar Serviços

#### Authentication

```bash
# No Firebase Console > Authentication
# 1. Ativar Email/Password
# 2. Configurar domínios autorizados
# 3. Configurar templates de email
```

#### Firestore Database

```bash
# No Firebase Console > Firestore Database
# 1. Criar banco em modo de produção
# 2. Escolher localização (us-east1 recomendado)
# 3. Configurar regras de segurança
```

#### Storage

```bash
# No Firebase Console > Storage
# 1. Iniciar Storage
# 2. Configurar regras de segurança
# 3. Definir localização
```

### 3. Configurar Regras de Segurança

#### Firestore Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários podem ler/escrever seus próprios dados
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Produtos são públicos para leitura
    match /produtos/{produtoId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }

    // Pedidos são privados por usuário
    match /pedidos/{pedidoId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.usuarioId;
    }
  }
}
```

#### Storage Rules

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Usuários podem fazer upload de suas próprias fotos
    match /usuarios/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null &&
        request.auth.uid == userId;
    }

    // Produtos são públicos para leitura
    match /produtos/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }
  }
}
```

### 4. Configurar Flutter

```bash
# Inicializar Firebase no projeto
firebase login
firebase init

# Selecionar serviços:
# - Firestore
# - Authentication
# - Storage
# - Hosting (para web)
```

### 5. Arquivos de Configuração

#### android/app/google-services.json

```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "mercado-facil-12345",
    "storage_bucket": "mercado-facil-12345.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef",
        "android_client_info": {
          "package_name": "com.mercadofacil.app"
        }
      }
    }
  ]
}
```

#### ios/Runner/GoogleService-Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>AIzaSy...</string>
    <key>GCM_SENDER_ID</key>
    <string>123456789</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.mercadofacil.app</string>
    <key>PROJECT_ID</key>
    <string>mercado-facil-12345</string>
    <key>STORAGE_BUCKET</key>
    <string>mercado-facil-12345.appspot.com</string>
    <key>IS_ADS_ENABLED</key>
    <false></false>
    <key>IS_ANALYTICS_ENABLED</key>
    <true></true>
    <key>IS_APPINVITE_ENABLED</key>
    <true></true>
    <key>IS_GCM_ENABLED</key>
    <true></true>
    <key>IS_SIGNIN_ENABLED</key>
    <true></true>
    <key>GOOGLE_APP_ID</key>
    <string>1:123456789:ios:abcdef</string>
</dict>
</plist>
```

## 🤖 Deploy Android

### 1. Configuração do Android

#### android/app/build.gradle

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.mercadofacil.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### android/key.properties

```properties
storePassword=sua_senha_keystore
keyPassword=sua_senha_chave
keyAlias=upload
storeFile=caminho/para/keystore.jks
```

### 2. Gerar Keystore

```bash
# Gerar keystore para assinatura
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Mover para pasta do projeto
mv ~/upload-keystore.jks android/app/
```

### 3. Build e Deploy

```bash
# Build APK de release
flutter build apk --release

# Build App Bundle (recomendado para Play Store)
flutter build appbundle --release

# Verificar APK
flutter build apk --analyze-size
```

### 4. Google Play Console

1. **Criar Conta**: Acesse [Google Play Console](https://play.google.com/console)
2. **Configurar App**:
   - Nome: "Mercado Fácil"
   - Categoria: "Compras"
   - Classificação: Livre
3. **Upload do Bundle**:
   - Faça upload do `app-release.aab`
   - Configure versão e release notes
4. **Configurações**:
   - Screenshots (pelo menos 2)
   - Ícone (512x512)
   - Descrição e palavras-chave
5. **Publicar**: Revisão interna → Produção

### 5. Teste Interno

```bash
# Build para teste interno
flutter build appbundle --release --flavor internal

# Upload para teste interno no Play Console
```

## 🍎 Deploy iOS

### 1. Configuração do iOS

#### ios/Runner.xcodeproj/project.pbxproj

```objc
// Configurar Bundle Identifier
PRODUCT_BUNDLE_IDENTIFIER = com.mercadofacil.app;

// Configurar versão
CURRENT_PROJECT_VERSION = 1;
MARKETING_VERSION = 1.0.0;
```

#### ios/Runner/Info.plist

```xml
<key>CFBundleDisplayName</key>
<string>Mercado Fácil</string>
<key>CFBundleIdentifier</key>
<string>com.mercadofacil.app</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### 2. Apple Developer Account

1. **Criar App ID**:
   - Bundle ID: `com.mercadofacil.app`
   - Capabilities: Push Notifications
2. **Criar Certificados**:
   - Distribution Certificate
   - Provisioning Profile
3. **Configurar Xcode**:
   - Team ID
   - Signing & Capabilities

### 3. Build e Deploy

```bash
# Build para iOS
flutter build ios --release

# Abrir no Xcode
open ios/Runner.xcworkspace

# No Xcode:
# 1. Selecionar dispositivo "Any iOS Device"
# 2. Product > Archive
# 3. Distribute App
# 4. App Store Connect
```

### 4. App Store Connect

1. **Criar App**:
   - Nome: "Mercado Fácil"
   - Bundle ID: `com.mercadofacil.app`
   - SKU: `mercado-facil-ios`
2. **Upload Build**:
   - Via Xcode ou Transporter
   - Aguardar processamento
3. **Configurar App**:
   - Screenshots (6.5" iPhone, 5.5" iPhone, 12.9" iPad)
   - Descrição e palavras-chave
   - Categoria: Shopping
4. **Submeter para Revisão**:
   - Preencher informações de privacidade
   - Responder perguntas de revisão

## 🌐 Deploy Web

### 1. Configuração do Web

#### web/index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <base href="$FLUTTER_BASE_HREF" />
    <meta charset="UTF-8" />
    <meta content="IE=Edge" http-equiv="X-UA-Compatible" />
    <meta name="description" content="Mercado Fácil - Suas compras online" />

    <!-- iOS meta tags & icons -->
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta name="apple-mobile-web-app-title" content="Mercado Fácil" />
    <link rel="apple-touch-icon" href="icons/Icon-192.png" />

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="favicon.png" />

    <title>Mercado Fácil</title>
    <link rel="manifest" href="manifest.json" />
  </head>
  <body>
    <script>
      var serviceWorkerVersion = null;
    </script>
    <script src="flutter.js" defer></script>
  </body>
</html>
```

#### web/manifest.json

```json
{
  "name": "Mercado Fácil",
  "short_name": "Mercado Fácil",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "Suas compras online de forma fácil e rápida",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 2. Build Web

```bash
# Build para web
flutter build web --release

# Build com otimizações
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### 3. Firebase Hosting

```bash
# Configurar Firebase Hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### firebase.json

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### 4. Domínio Personalizado

```bash
# Adicionar domínio personalizado
firebase hosting:channel:deploy preview --expires 7d

# Configurar domínio
firebase hosting:sites:add mercadofacil.com
```

## 🖥️ Deploy Desktop

### 1. Configuração do Desktop

#### windows/runner/main.cpp

```cpp
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Mercado Fácil", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
```

### 2. Build Desktop

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

### 3. Distribuição

#### Windows (MSI)

```bash
# Usar ferramentas como Inno Setup ou WiX
# Criar instalador MSI
```

#### macOS (DMG)

```bash
# Criar DMG com ferramentas como create-dmg
create-dmg \
  --volname "Mercado Fácil" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "Mercado Fácil.app" 200 190 \
  --hide-extension "Mercado Fácil.app" \
  --app-drop-link 600 185 \
  "Mercado Fácil.dmg" \
  "build/macos/Build/Products/Release/"
```

## 🔄 CI/CD com GitHub Actions

### 1. Configuração do Workflow

#### .github/workflows/deploy.yml

```yaml
name: Deploy Mercado Fácil

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.19.0"
          channel: "stable"

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.19.0"

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: "zulu"
          java-version: "17"

      - name: Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks

      - name: Build APK
        run: flutter build appbundle --release

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_CONFIG_JSON }}
          packageName: com.mercadofacil.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal

  deploy-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.19.0"

      - name: Build Web
        run: flutter build web --release

      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: "${{ secrets.GITHUB_TOKEN }}"
          firebaseServiceAccount: "${{ secrets.FIREBASE_SERVICE_ACCOUNT }}"
          channelId: live
          projectId: mercado-facil-12345
```

### 2. Secrets Necessários

```bash
# No GitHub Repository > Settings > Secrets
KEYSTORE_BASE64=base64_do_keystore
PLAY_STORE_CONFIG_JSON=json_da_conta_de_servico
FIREBASE_SERVICE_ACCOUNT=json_da_conta_firebase
```

### 3. Configuração de Branches

```bash
# main - produção
# develop - desenvolvimento
# feature/* - features
# hotfix/* - correções urgentes
```

## 📊 Monitoramento e Analytics

### 1. Firebase Analytics

```dart
// lib/main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configurar Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.setAnalyticsCollectionEnabled(true);

  runApp(MyApp());
}
```

### 2. Crashlytics

```dart
// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configurar Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MyApp());
}
```

### 3. Performance Monitoring

```dart
// lib/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  static Future<void> startTrace(String traceName) async {
    final trace = _performance.newTrace(traceName);
    await trace.start();
  }

  static Future<void> stopTrace(String traceName) async {
    final trace = _performance.newTrace(traceName);
    await trace.stop();
  }
}
```

## 🔧 Troubleshooting

### Problemas Comuns

#### Build Android Falha

```bash
# Limpar cache
flutter clean
flutter pub get

# Verificar versão do Java
java -version

# Verificar keystore
keytool -list -v -keystore android/app/keystore.jks
```

#### Build iOS Falha

```bash
# Limpar cache
flutter clean
flutter pub get

# Limpar Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean

# Verificar certificados
security find-identity -v -p codesigning
```

#### Deploy Web Falha

```bash
# Verificar Firebase CLI
firebase --version

# Verificar login
firebase login

# Verificar projeto
firebase projects:list

# Limpar cache
firebase hosting:clear
```

#### Problemas de Performance

```dart
// Otimizar imagens
CachedNetworkImage(
  imageUrl: produto.imagemUrl,
  memCacheWidth: 300,
  memCacheHeight: 300,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// Otimizar listas
ListView.builder(
  itemCount: produtos.length,
  itemBuilder: (context, index) {
    return ProdutoCard(produto: produtos[index]);
  },
)
```

### Logs e Debug

```bash
# Logs do Flutter
flutter logs

# Logs do Firebase
firebase functions:log

# Logs do Android
adb logcat

# Logs do iOS
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'
```

### Métricas de Performance

```dart
// Medir tempo de carregamento
final stopwatch = Stopwatch()..start();
await carregarProdutos();
stopwatch.stop();
print('Tempo de carregamento: ${stopwatch.elapsedMilliseconds}ms');

// Medir uso de memória
import 'dart:io';
print('Memória usada: ${ProcessInfo.currentRss} bytes');
```

---

## 📞 Suporte

Para problemas de deploy, entre em contato:

- **Email**: deploy@mercadofacil.com
- **Issues**: [GitHub Issues](https://github.com/seu-usuario/mercado_facil/issues)
- **Documentação**: [Wiki do Projeto](https://github.com/seu-usuario/mercado_facil/wiki)

---

**Deploy bem-sucedido! 🚀✨**
