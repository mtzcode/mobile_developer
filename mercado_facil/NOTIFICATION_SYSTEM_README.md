# Sistema de Notificações Multi-Canal - Mercado Fácil

## 📋 Visão Geral

Este documento descreve o sistema completo de notificações multi-canal implementado no aplicativo Mercado Fácil. O sistema permite enviar notificações através de múltiplos canais (Push, Email) baseado nas preferências do usuário.

## 🚀 Funcionalidades Implementadas

### ✅ Tipos de Notificação

1. **Produtos Favoritos em Promoção**
   - Detecta automaticamente quando produtos favoritados entram em promoção
   - Envia notificações personalizadas com detalhes da oferta
   - Controla frequência para evitar spam

2. **Lembretes de Carrinho Abandonado**
   - Monitora carrinhos inativos
   - Envia lembretes em intervalos configuráveis (1h, 24h, 7 dias)
   - Personaliza mensagens baseado no conteúdo do carrinho

3. **Novos Produtos**
   - Notifica sobre produtos recém-adicionados
   - Filtra por categorias de interesse do usuário

4. **Alertas de Preço**
   - Monitora mudanças significativas de preço
   - Notifica sobre reduções em produtos favoritados

### ✅ Canais de Notificação

1. **Push Notifications (FCM)**
   - Notificações nativas no dispositivo
   - Suporte para Android e Web
   - Funciona em background

2. **Email**
   - Integração com SendGrid API
   - Templates HTML personalizados
   - Suporte a anexos e imagens



## 🏗️ Arquitetura do Sistema

### Componentes Principais

```
📁 lib/data/services/
├── 📄 email_service.dart                    # Serviço de envio de emails

├── 📄 multi_channel_notification_service.dart # Orquestrador multi-canal
├── 📄 favorites_promotion_detector.dart     # Detector de promoções
├── 📄 cart_reminder_service.dart           # Serviço de lembretes de carrinho
└── 📄 notification_scheduler.dart          # Agendador central

📁 lib/data/providers/
└── 📄 notification_scheduler_provider.dart # Providers Riverpod

📁 lib/presentation/screens/admin/
└── 📄 notification_admin_screen.dart       # Tela de administração

📁 lib/data/models/
└── 📄 notification_model.dart              # Modelos expandidos
```

### Fluxo de Funcionamento

1. **Inicialização**
   ```dart
   // No main.dart
   _initializeNotificationSystem()
   ```

2. **Detecção de Eventos**
   - `FavoritesPromotionDetector` monitora mudanças de preço
   - `CartReminderService` verifica carrinhos inativos
   - `NotificationScheduler` coordena verificações periódicas

3. **Processamento**
   - Verifica preferências do usuário
   - Seleciona canais apropriados
   - Personaliza conteúdo da mensagem

4. **Envio Multi-Canal**
   ```dart
   await multiChannelService.enviarNotificacaoFavoritoPromocao(
     usuario,
     produto,
     precoAntigo,
     settings,
   );
   ```

## ⚙️ Configuração

### 1. Configurações do Firebase

```dart
// firebase_options.dart já configurado
// FCM configurado para Android e Web
```

### 2. Configurações de Email (SendGrid)

**IMPORTANTE**: Para que os emails funcionem, você precisa configurar as chaves do SendGrid:

#### 2.1. Obter Chave da API SendGrid
1. Acesse [SendGrid](https://sendgrid.com) e crie uma conta
2. Vá em Settings > API Keys
3. Crie uma nova API Key com permissões de envio de email
4. Copie a chave gerada (formato: `SG.xxxxxxxxxx`)

#### 2.2. Configurar no Projeto

**Opção A: Arquivo .env (Recomendado)**
```bash
# Adicione no arquivo .env
SENDGRID_API_KEY=SG.sua_chave_sendgrid_aqui
SENDGRID_FROM_EMAIL=noreply@seudominio.com
SENDGRID_FROM_NAME=Mercado Fácil
```

**Opção B: Direto no código (apenas para testes)**
```dart
// Em lib/data/services/email_service.dart
static const String _apiKey = 'SG.sua_chave_sendgrid_aqui';
static const String _fromEmail = 'noreply@seudominio.com';
static const String _fromName = 'Mercado Fácil';
```

#### 2.3. Verificar Domínio de Envio
- Configure um domínio verificado no SendGrid
- Use um email do domínio verificado como remetente
- Para testes, você pode usar emails sandbox do SendGrid



### 4. Preferências do Usuário

```dart
// Modelo expandido em notification_model.dart
class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;

  final bool favoritePromotions;    // ✅ Novo
  final bool cartReminders;         // ✅ Novo
  final bool newProducts;           // ✅ Novo
  final bool priceAlerts;           // ✅ Novo
}
```

## 🎯 Como Usar

### 1. Inicialização Automática

O sistema é inicializado automaticamente quando o app inicia:

```dart
// main.dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _initializeNotificationSystem();
});
```

### 2. Controle via Provider

```dart
// Em qualquer widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulerState = ref.watch(notificationSchedulerStateProvider);
    
    return Column(
      children: [
        Text('Status: ${schedulerState.isRunning ? "Ativo" : "Inativo"}'),
        ElevatedButton(
          onPressed: () {
            ref.read(notificationSchedulerStateProvider.notifier).start();
          },
          child: Text('Iniciar Agendador'),
        ),
      ],
    );
  }
}
```

### 3. Tela de Administração

Acesse `/notification-admin` para:
- Visualizar status do sistema
- Controlar o agendador
- Ver estatísticas em tempo real
- Executar tarefas manualmente

### 4. Gerenciamento de Configurações do Usuário

```dart
// Carregar configurações do usuário
final notificationService = NotificationService();
final userId = 'user123';
final settings = await notificationService.getNotificationSettings(userId);

// Modificar configurações
final newSettings = settings.copyWith(
  emailEnabled: true,
  pushEnabled: true,
  promotions: false,
  favoritePromotions: true,
  cartReminders: true,
);

// Salvar configurações (persiste no Firestore + cache local)
await notificationService.saveUserNotificationSettings(userId, newSettings);

// Sincronizar configurações offline com Firestore
await notificationService.syncNotificationSettings(userId);

// Verificar se há configurações pendentes de sincronização
final hasPending = await notificationService.hasPendingSync(userId);

// Obter estatísticas para debug
final stats = await notificationService.getSettingsStats(userId);
print('Configurações no Firestore: ${stats['hasFirestoreSettings']}');
print('Cache local: ${stats['hasLocalCache']}');
```

### 5. Envio Manual de Notificações

```dart
// Exemplo de uso direto
final multiChannelService = MultiChannelNotificationService();

await multiChannelService.enviarNotificacaoFavoritoPromocao(
  usuario,
  produto,
  precoAntigo,
  settings,
);
```

## 📊 Monitoramento e Estatísticas

### Métricas Disponíveis

- Total de notificações enviadas
- Taxa de sucesso por canal
- Notificações por tipo
- Erros e falhas
- Performance do sistema

### Logs Detalhados

```dart
// Sistema de logging integrado
AppLogger.info('Notificação enviada com sucesso');
AppLogger.error('Erro no envio', error, stackTrace);
```

## 🔧 Manutenção

### Tarefas Automáticas

1. **A cada 15 minutos**
   - Verificação de promoções
   - Lembretes de carrinho
   - Alertas de preço

2. **Diariamente**
   - Limpeza de dados antigos
   - Backup de estatísticas
   - Relatórios para administradores

3. **Semanalmente**
   - Limpeza profunda
   - Análise de tendências
   - Otimização de performance

### Configurações do Agendador

```dart
// notification_scheduler.dart
static const Duration _mainCheckInterval = Duration(minutes: 15);
static const Duration _dailyTasksInterval = Duration(hours: 24);
static const Duration _weeklyTasksInterval = Duration(days: 7);
```

## 🚨 Tratamento de Erros

### Estratégias Implementadas

1. **Retry Automático**
   - 3 tentativas com backoff exponencial
   - Fallback para outros canais em caso de falha

2. **Circuit Breaker**
   - Para serviços externos (SendGrid, WhatsApp)
   - Evita sobrecarga em caso de instabilidade

3. **Logs Detalhados**
   - Rastreamento completo de erros
   - Stack traces para debugging

4. **Notificações de Falha**
   - Alertas para administradores
   - Monitoramento de saúde do sistema

## 🔐 Segurança

### Medidas Implementadas

1. **Validação de Dados**
   - Sanitização de inputs
   - Validação de formatos (email, telefone)

2. **Rate Limiting**
   - Controle de frequência por usuário
   - Prevenção de spam

3. **Autenticação**
   - Tokens seguros para APIs externas
   - Validação de permissões

4. **Privacidade**
   - Respeito às preferências do usuário
   - Opt-out fácil

## 📱 Compatibilidade

### Plataformas Suportadas

- ✅ Android (FCM nativo)
- ✅ Web (FCM via Service Worker) - **Limitações**: Apenas push notifications
- ✅ Email (universal)

**IMPORTANTE sobre Notificações Web:**
- Push notifications funcionam apenas quando o usuário dá permissão
- Emails NÃO são enviados automaticamente na versão web
- Para testar emails, use a versão mobile ou configure um servidor backend
- Service Worker precisa estar ativo para receber notificações em background


### Requisitos

- Flutter 3.0+
- Firebase SDK
- Riverpod 2.0+
- Conectividade com internet

## 🎨 Personalização

### Templates de Email

```dart
// Personalize em email_service.dart
String _buildFavoritePromotionEmailHtml(Usuario usuario, Produto produto, double precoAntigo) {
  return '''
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <!-- Seu template personalizado aqui -->
    </div>
  ''';
}
```



## 💾 Persistência de Configurações

### Como as Configurações são Armazenadas

**IMPORTANTE**: As configurações de notificação são armazenadas de forma híbrida:

#### 1. Configurações do Usuário (Persistentes)
- **Local**: SharedPreferences (cache local)
- **Remoto**: Firestore (vinculado ao usuário)
- **Comportamento**: Mantidas entre builds e reinstalações

#### 2. Configurações Temporárias (Cache)
- **Local**: Memória da aplicação
- **Comportamento**: Perdidas ao fechar o app

### Por que as Configurações "Somem" ao Fazer Build?

**Explicação**: Durante o desenvolvimento, as configurações podem ser perdidas por:

1. **Hot Reload/Restart**: Limpa a memória, mas mantém SharedPreferences
2. **Flutter Clean**: Remove cache local, mas mantém dados do Firestore
3. **Reinstalação**: Remove SharedPreferences, mas dados do usuário ficam no Firestore
4. **Logout/Login**: Recarrega configurações do servidor

### Como Garantir Persistência

```dart
// As configurações são salvas automaticamente quando alteradas
await notificationProvider.updateSettings(newSettings);

// Para forçar sincronização com o servidor:
await notificationService.syncUserSettings(userId);
```

## 🔧 Troubleshooting

### Emails Não Chegam

**Possíveis Causas:**
1. **Chave SendGrid não configurada**
   - Verifique se `SENDGRID_API_KEY` está no .env
   - Confirme se a chave tem permissões de envio

2. **Domínio não verificado**
   - Configure sender authentication no SendGrid
   - Use um email de domínio verificado

3. **Configurações do usuário**
   - Verifique se `emailEnabled: true` nas configurações
   - Confirme se o tipo de notificação está ativo

4. **Versão Web**
   - Emails não funcionam na versão web sem backend
   - Use a versão mobile para testar

**Como Testar:**
```dart
// Teste manual de email
final emailService = EmailService();
final result = await emailService.enviarEmailTeste('seu@email.com');
print('Email enviado: $result');
```

### Push Notifications Não Aparecem

**Possíveis Causas:**
1. **Permissões não concedidas**
   - Solicite permissão: `await messaging.requestPermission()`
   - Verifique nas configurações do dispositivo

2. **Token FCM inválido**
   - Token pode expirar ou mudar
   - Implemente refresh automático

3. **Service Worker (Web)**
   - Verifique se `firebase-messaging-sw.js` está configurado
   - Confirme se o service worker está ativo

4. **App em background**
   - Algumas configurações podem bloquear notificações
   - Teste com app em foreground primeiro

### Configurações Não Persistem

**Soluções:**
1. **Verificar login do usuário**
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     // Usuário não logado - configurações não serão salvas
   }
   ```

2. **Forçar sincronização**
   ```dart
   // Salvar localmente E remotamente
   await notificationService.saveSettingsLocal(settings);
   await notificationService.saveSettingsRemote(userId, settings);
   ```

3. **Verificar permissões do Firestore**
   - Confirme se as regras permitem escrita
   - Verifique se o usuário está autenticado

### Logs para Debug

```dart
// Ativar logs detalhados
AppLogger.setLevel(LogLevel.debug);

// Verificar status do sistema
final status = await notificationScheduler.getSystemStatus();
print('Status: $status');

// Verificar configurações do usuário
final settings = await notificationService.getNotificationSettings(userId);
print('Configurações: $settings');
```

## 🚀 Próximos Passos

### Melhorias Futuras

1. **Segmentação Avançada**
   - Notificações baseadas em comportamento
   - Machine Learning para personalização

2. **Canais Adicionais**
   - SMS
   - Telegram
   - Slack (para administradores)

3. **Analytics Avançados**
   - Dashboard em tempo real
   - Métricas de engajamento
   - A/B testing

4. **Automação Inteligente**
   - Horários otimizados por usuário
   - Frequência adaptativa
   - Conteúdo dinâmico

## 📞 Suporte

Para dúvidas ou problemas:

1. Verifique os logs do sistema
2. Acesse a tela de administração
3. Consulte este documento
4. Entre em contato com a equipe de desenvolvimento

---

**Sistema implementado com ❤️ para o Mercado Fácil**

*Última atualização: $(date)*