# 🔒 Guia de Segurança - Mercado Fácil

## 📋 Visão Geral

Este documento descreve as medidas de segurança implementadas no aplicativo Mercado Fácil para proteger dados dos usuários e garantir a integridade do sistema.

## 🛡️ Medidas de Segurança Implementadas

### 1. Firebase App Check

**Status:** ✅ Habilitado

- **Desenvolvimento:** Usa `AndroidProvider.debug` e `AppleProvider.debug`
- **Produção:** Deve usar `AndroidProvider.playIntegrity` e `AppleProvider.appAttest`
- **Web:** Configurado com reCAPTCHA v3 (requer configuração da chave)

**Configuração:**
```dart
// Em main.dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.debug, // Mude para playIntegrity em produção
  appleProvider: AppleProvider.debug,     // Mude para appAttest em produção
  webProvider: ReCaptchaV3Provider('sua_chave_recaptcha'),
);
```

### 2. Regras Restritivas do Firestore

**Status:** ✅ Implementadas

#### Principais Melhorias:

- **Usuários:** Acesso apenas aos próprios dados com validação
- **Produtos:** Leitura pública, escrita bloqueada (apenas Admin SDK)
- **Endereços:** Acesso restrito ao proprietário com validação
- **Pedidos:** Acesso restrito ao proprietário
- **Carrinhos:** Acesso restrito ao proprietário
- **Removida regra genérica:** Eliminada a regra `match /{document=**}`

#### Validações Implementadas:

```javascript
// Validação de dados do usuário
function validateUserData(data) {
  return data.keys().hasAll(['nome', 'email']) &&
         data.nome is string &&
         data.email is string &&
         data.nome.size() > 0 &&
         data.email.matches('.*@.*\..*');
}

// Validação de dados de endereço
function validateEnderecoData(data) {
  return data.keys().hasAll(['cep', 'logradouro', 'numero', 'bairro', 'uf', 'usuarioId']) &&
         // ... validações de tipo
}
```

### 3. Variáveis de Ambiente

**Status:** ✅ Configuradas

#### Arquivos Criados:

- `lib/core/config/environment_config.dart` - Configuração centralizada
- `.env.example` - Template de variáveis de ambiente
- `.gitignore` atualizado - Proteção de arquivos sensíveis

#### Variáveis Importantes:

```bash
# Segurança
FIREBASE_API_KEY=sua_chave_aqui
RECAPTCHA_SITE_KEY=sua_chave_recaptcha
ENCRYPTION_KEY=chave_32_caracteres

# Ambiente
PRODUCTION=false
DEBUG_LOGS=true
ENABLE_ANALYTICS=true
```

## 🚀 Configuração para Produção

### 1. Firebase App Check

```bash
# Configure no Firebase Console:
# 1. Ative App Check
# 2. Configure Play Integrity (Android)
# 3. Configure App Attest (iOS)
# 4. Configure reCAPTCHA v3 (Web)
```

### 2. Variáveis de Ambiente

```bash
# Build para produção
flutter build apk --dart-define=PRODUCTION=true \
  --dart-define=FIREBASE_API_KEY=sua_chave_real \
  --dart-define=RECAPTCHA_SITE_KEY=sua_chave_recaptcha \
  --dart-define=ENCRYPTION_KEY=sua_chave_criptografia
```

### 3. Regras do Firestore

```bash
# Deploy das regras
firebase deploy --only firestore:rules
```

## 🔍 Validações de Segurança

### Checklist de Produção:

- [ ] Firebase App Check configurado com providers de produção
- [ ] Chave reCAPTCHA v3 configurada
- [ ] Regras do Firestore deployadas
- [ ] Variáveis de ambiente configuradas
- [ ] Chaves de API protegidas
- [ ] Logs de debug desabilitados
- [ ] Certificados de produção configurados

### Verificação Automática:

```dart
// Use EnvironmentConfig.isConfigurationValid
if (!EnvironmentConfig.isConfigurationValid) {
  throw Exception('Configuração de produção inválida');
}
```

## 🛠️ Monitoramento

### Logs de Segurança:

- App Check: Monitore tentativas de acesso não autorizadas
- Firestore: Monitore violações de regras
- Authentication: Monitore tentativas de login suspeitas

### Alertas Recomendados:

1. **App Check failures** - Possíveis ataques
2. **Firestore rule violations** - Tentativas de acesso não autorizado
3. **Authentication anomalies** - Logins suspeitos
4. **API rate limiting** - Possível abuso

## 📚 Recursos Adicionais

- [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)

## 🔄 Atualizações

**Última atualização:** Janeiro 2025

**Próximas melhorias planejadas:**
- Implementação de rate limiting
- Criptografia de dados sensíveis
- Auditoria de segurança automatizada
- Implementação de CSP (Content Security Policy)

---

**⚠️ Importante:** Mantenha este documento atualizado conforme novas medidas de segurança são implementadas.