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

```dart
// Em email_service.dart
static const String _apiKey = 'SG.your_sendgrid_api_key';
static const String _fromEmail = 'noreply@mercadofacil.com';
static const String _fromName = 'Mercado Fácil';
```



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

### 4. Envio Manual de Notificações

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
- ✅ Web (FCM via Service Worker)
- ✅ Email (universal)


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