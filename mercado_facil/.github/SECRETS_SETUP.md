# 🔐 Configuração de Secrets - GitHub Actions

Este documento explica como configurar os secrets necessários para os workflows de CI/CD do Mercado Fácil.

## 📋 Secrets Necessários

### 1. **KEYSTORE_BASE64**

**Descrição**: Keystore do Android codificado em base64 para assinatura do APK.

**Como obter**:

```bash
# Gerar keystore (se ainda não tiver)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Converter para base64
base64 -i upload-keystore.jks | tr -d '\n'
```

**Configuração**:

1. Vá para `Settings` > `Secrets and variables` > `Actions`
2. Clique em `New repository secret`
3. Nome: `KEYSTORE_BASE64`
4. Valor: Resultado do comando base64 acima

### 2. **FIREBASE_SERVICE_ACCOUNT**

**Descrição**: JSON da conta de serviço do Firebase para deploy.

**Como obter**:

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Vá para `Project Settings` > `Service accounts`
3. Clique em `Generate new private key`
4. Baixe o arquivo JSON

**Configuração**:

1. Vá para `Settings` > `Secrets and variables` > `Actions`
2. Clique em `New repository secret`
3. Nome: `FIREBASE_SERVICE_ACCOUNT`
4. Valor: Conteúdo completo do arquivo JSON

### 3. **FIREBASE_PROJECT_ID**

**Descrição**: ID do projeto Firebase.

**Como obter**:

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. O ID do projeto está na URL: `https://console.firebase.google.com/project/SEU_PROJECT_ID`

**Configuração**:

1. Vá para `Settings` > `Secrets and variables` > `Actions`
2. Clique em `New repository secret`
3. Nome: `FIREBASE_PROJECT_ID`
4. Valor: ID do seu projeto Firebase

### 4. **PLAY_STORE_CONFIG_JSON**

**Descrição**: JSON da conta de serviço do Google Play Console.

**Como obter**:

1. Acesse [Google Play Console](https://play.google.com/console)
2. Vá para `Setup` > `API access`
3. Clique em `Create new service account`
4. Baixe o arquivo JSON

**Configuração**:

1. Vá para `Settings` > `Secrets and variables` > `Actions`
2. Clique em `New repository secret`
3. Nome: `PLAY_STORE_CONFIG_JSON`
4. Valor: Conteúdo completo do arquivo JSON

### 5. **CODECOV_TOKEN** (Opcional)

**Descrição**: Token do Codecov para upload de relatórios de cobertura.

**Como obter**:

1. Acesse [Codecov](https://codecov.io/)
2. Conecte seu repositório
3. Copie o token do projeto

**Configuração**:

1. Vá para `Settings` > `Secrets and variables` > `Actions`
2. Clique em `New repository secret`
3. Nome: `CODECOV_TOKEN`
4. Valor: Token do Codecov

## 🔧 Configuração do Android

### 1. Configurar Keystore

Crie o arquivo `android/key.properties`:

```properties
storePassword=sua_senha_keystore
keyPassword=sua_senha_chave
keyAlias=upload
storeFile=../app/keystore.jks
```

### 2. Configurar build.gradle

Atualize `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
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

## 🔥 Configuração do Firebase

### 1. Inicializar Firebase

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Fazer login
firebase login

# Inicializar projeto
firebase init
```

### 2. Configurar firebase.json

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
    ]
  }
}
```

## 📱 Configuração do Google Play Console

### 1. Criar App

1. Acesse [Google Play Console](https://play.google.com/console)
2. Clique em `Create app`
3. Preencha as informações:
   - App name: Mercado Fácil
   - Default language: Portuguese (Brazil)
   - App or game: App
   - Free or paid: Free

### 2. Configurar API Access

1. Vá para `Setup` > `API access`
2. Clique em `Create new service account`
3. Siga as instruções para criar a conta de serviço
4. Baixe o arquivo JSON

### 3. Configurar Release

1. Vá para `Release` > `Production`
2. Crie uma nova release
3. Configure as informações necessárias

## 🧪 Configuração de Testes

### 1. Configurar Codecov (Opcional)

1. Acesse [Codecov](https://codecov.io/)
2. Conecte seu repositório GitHub
3. Copie o token do projeto
4. Adicione como secret `CODECOV_TOKEN`

### 2. Configurar Testes Locais

```bash
# Executar todos os testes
flutter test --coverage

# Gerar relatório de cobertura
genhtml coverage/lcov.info -o coverage/html

# Abrir relatório
open coverage/html/index.html
```

## 🔍 Verificação da Configuração

### 1. Testar Secrets

Crie um workflow de teste:

```yaml
name: Test Secrets
on: [workflow_dispatch]

jobs:
  test-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Test Firebase Project ID
        run: echo "Firebase Project ID: ${{ secrets.FIREBASE_PROJECT_ID }}"

      - name: Test Keystore
        run: |
          if [ -n "${{ secrets.KEYSTORE_BASE64 }}" ]; then
            echo "✅ Keystore configurado"
          else
            echo "❌ Keystore não configurado"
          fi
```

### 2. Verificar Permissões

Certifique-se de que:

- O repositório tem permissões para executar GitHub Actions
- As contas de serviço têm as permissões necessárias
- Os tokens não expiraram

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. **Erro de Keystore**

```
Error: Keystore file not found
```

**Solução**: Verifique se o `KEYSTORE_BASE64` está configurado corretamente.

#### 2. **Erro de Firebase**

```
Error: Firebase project not found
```

**Solução**: Verifique se o `FIREBASE_PROJECT_ID` está correto.

#### 3. **Erro de Google Play**

```
Error: Authentication failed
```

**Solução**: Verifique se o `PLAY_STORE_CONFIG_JSON` está correto e a conta tem permissões.

#### 4. **Erro de Permissões**

```
Error: Permission denied
```

**Solução**: Verifique as permissões da conta de serviço no Google Play Console.

## 📞 Suporte

Para problemas com secrets:

- **Email**: devops@mercadofacil.com
- **Issues**: [GitHub Issues](https://github.com/seu-usuario/mercado_facil/issues)
- **Documentação**: [Wiki do Projeto](https://github.com/seu-usuario/mercado_facil/wiki)

---

**Configuração completa! 🚀✨**
