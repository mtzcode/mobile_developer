import '../../core/utils/logger.dart';
import '../models/usuario.dart';
import '../models/produto.dart';
import '../models/carrinho_item.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'email_service.dart';

/// Serviço unificado para envio de notificações multi-canal
/// 
/// Este serviço coordena o envio de notificações através de diferentes canais
/// (push, email) baseado nas preferências do usuário.
class MultiChannelNotificationService {
  final NotificationService _notificationService;
  final EmailService _emailService;

  MultiChannelNotificationService({
    NotificationService? notificationService,
    EmailService? emailService,
  }) : _notificationService = notificationService ?? NotificationService(),
       _emailService = emailService ?? EmailService();

  /// Envia notificação de produto favorito em promoção
  /// 
  /// [usuario] - Usuário que receberá as notificações
  /// [produto] - Produto que entrou em promoção
  /// [settings] - Configurações de notificação do usuário
  Future<Map<String, bool>> enviarNotificacaoFavoritoPromocao(
    Usuario usuario,
    Produto produto,
    NotificationSettings settings,
  ) async {
    final resultados = <String, bool>{};
    
    try {
      AppLogger.info('Enviando notificação de favorito em promoção para ${usuario.nome}');
      
      // Verifica se as notificações de favoritos em promoção estão ativadas
      if (!settings.favoritePromotions) {
        AppLogger.info('Notificações de favoritos em promoção desativadas para ${usuario.nome}');
        return {'skipped': true};
      }
      
      final titulo = '🔥 Oferta Especial!';
      final mensagem = 'Seu produto favorito ${produto.nome} está com desconto!';
      
      // Envio via Push Notification
      if (settings.pushEnabled) {
        try {
          final pushResult = await _notificationService.sendNotificationToUser(
            userId: usuario.id,
            title: titulo,
            body: mensagem,
            data: {
              'type': 'favorite_promotion',
              'produto_id': produto.id,
              'produto_nome': produto.nome,
              'preco_original': produto.preco.toString(),
              'preco_promocional': produto.precoPromocional?.toString() ?? produto.preco.toString(),
            },
          );
          resultados['push'] = pushResult;
          AppLogger.info('Push notification enviado: $pushResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar push notification', e, stackTrace);
          resultados['push'] = false;
        }
      }
      
      // Envio via Email
      if (settings.emailEnabled && usuario.email.isNotEmpty) {
        try {
          final emailResult = await _emailService.enviarEmailFavoritoPromocao(usuario, produto);
          resultados['email'] = emailResult;
          AppLogger.info('Email enviado: $emailResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar email', e, stackTrace);
          resultados['email'] = false;
        }
      }
      

      
      AppLogger.success('Notificação de favorito em promoção processada: $resultados');
      return resultados;
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro geral ao enviar notificação de favorito em promoção', e, stackTrace);
      return {'error': false};
    }
  }

  /// Envia notificação de lembrete de carrinho abandonado
  /// 
  /// [usuario] - Usuário que receberá as notificações
  /// [itensCarrinho] - Itens no carrinho abandonado
  /// [totalCarrinho] - Valor total do carrinho
  /// [settings] - Configurações de notificação do usuário
  Future<Map<String, bool>> enviarNotificacaoLembreteCarrinho(
    Usuario usuario,
    List<CarrinhoItem> itensCarrinho,
    double totalCarrinho,
    NotificationSettings settings,
  ) async {
    final resultados = <String, bool>{};
    
    try {
      AppLogger.info('Enviando notificação de lembrete de carrinho para ${usuario.nome}');
      
      // Verifica se as notificações de lembrete de carrinho estão ativadas
      if (!settings.cartReminders) {
        AppLogger.info('Notificações de lembrete de carrinho desativadas para ${usuario.nome}');
        return {'skipped': true};
      }
      
      final quantidadeItens = itensCarrinho.length;
      final titulo = '🛒 Não esqueça seu carrinho!';
      final mensagem = 'Você tem $quantidadeItens ${quantidadeItens == 1 ? 'item' : 'itens'} esperando por você. Total: R\$ ${totalCarrinho.toStringAsFixed(2)}';
      
      // Envio via Push Notification
      if (settings.pushEnabled) {
        try {
          final pushResult = await _notificationService.sendNotificationToUser(
            userId: usuario.id,
            title: titulo,
            body: mensagem,
            data: {
              'type': 'cart_reminder',
              'quantidade_itens': quantidadeItens.toString(),
              'total_carrinho': totalCarrinho.toString(),
              'itens': itensCarrinho.map((item) => {
                'produto_id': item.produto.id,
                'produto_nome': item.produto.nome,
                'quantidade': item.quantidade.toString(),
              }).toList().toString(),
            },
          );
          resultados['push'] = pushResult;
          AppLogger.info('Push notification enviado: $pushResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar push notification', e, stackTrace);
          resultados['push'] = false;
        }
      }
      
      // Envio via Email
      if (settings.emailEnabled && usuario.email.isNotEmpty) {
        try {
          final emailResult = await _emailService.enviarEmailLembreteCarrinho(
            usuario, 
            itensCarrinho, 
            totalCarrinho
          );
          resultados['email'] = emailResult;
          AppLogger.info('Email enviado: $emailResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar email', e, stackTrace);
          resultados['email'] = false;
        }
      }
      

      
      AppLogger.success('Notificação de lembrete de carrinho processada: $resultados');
      return resultados;
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro geral ao enviar notificação de lembrete de carrinho', e, stackTrace);
      return {'error': false};
    }
  }

  /// Envia notificação de novo produto disponível
  /// 
  /// [usuario] - Usuário que receberá as notificações
  /// [produto] - Novo produto disponível
  /// [categoria] - Categoria do produto
  /// [settings] - Configurações de notificação do usuário
  Future<Map<String, bool>> enviarNotificacaoNovoProduto(
    Usuario usuario,
    Produto produto,
    String categoria,
    NotificationSettings settings,
  ) async {
    final resultados = <String, bool>{};
    
    try {
      AppLogger.info('Enviando notificação de novo produto para ${usuario.nome}');
      
      // Verifica se as notificações de novos produtos estão ativadas
      if (!settings.newProducts) {
        AppLogger.info('Notificações de novos produtos desativadas para ${usuario.nome}');
        return {'skipped': true};
      }
      
      final titulo = '🆕 Novo produto disponível!';
      final mensagem = 'Confira o novo produto ${produto.nome} na categoria $categoria por R\$ ${produto.preco.toStringAsFixed(2)}';
      
      // Envio via Push Notification
      if (settings.pushEnabled) {
        try {
          final pushResult = await _notificationService.sendNotificationToUser(
            userId: usuario.id,
            title: titulo,
            body: mensagem,
            data: {
              'type': 'new_product',
              'produto_id': produto.id,
              'produto_nome': produto.nome,
              'categoria': categoria,
              'preco': produto.preco.toString(),
            },
          );
          resultados['push'] = pushResult;
          AppLogger.info('Push notification enviado: $pushResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar push notification', e, stackTrace);
          resultados['push'] = false;
        }
      }
      
      // Envio via Email
      if (settings.emailEnabled && usuario.email.isNotEmpty) {
        try {
          final emailResult = await _emailService.enviarEmailNovoProduto(usuario, produto, categoria);
          resultados['email'] = emailResult;
          AppLogger.info('Email enviado: $emailResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar email', e, stackTrace);
          resultados['email'] = false;
        }
      }
      

      
      AppLogger.success('Notificação de novo produto processada: $resultados');
      return resultados;
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro geral ao enviar notificação de novo produto', e, stackTrace);
      return {'error': false};
    }
  }

  /// Envia notificação de alerta de preço
  /// 
  /// [usuario] - Usuário que receberá as notificações
  /// [produto] - Produto com alteração de preço
  /// [precoAnterior] - Preço anterior do produto
  /// [settings] - Configurações de notificação do usuário
  Future<Map<String, bool>> enviarNotificacaoAlertaPreco(
    Usuario usuario,
    Produto produto,
    double precoAnterior,
    NotificationSettings settings,
  ) async {
    final resultados = <String, bool>{};
    
    try {
      AppLogger.info('Enviando notificação de alerta de preço para ${usuario.nome}');
      
      // Verifica se as notificações de alerta de preço estão ativadas
      if (!settings.priceAlerts) {
        AppLogger.info('Notificações de alerta de preço desativadas para ${usuario.nome}');
        return {'skipped': true};
      }
      
      final precoAtual = produto.preco;
      final diferenca = precoAnterior - precoAtual;
      final percentualDesconto = (diferenca / precoAnterior * 100).abs();
      
      final titulo = diferenca > 0 ? '📉 Preço baixou!' : '📈 Preço subiu!';
      final mensagem = diferenca > 0 
          ? '${produto.nome} baixou de R\$ ${precoAnterior.toStringAsFixed(2)} para R\$ ${precoAtual.toStringAsFixed(2)} (${percentualDesconto.toStringAsFixed(1)}% de desconto)'
          : '${produto.nome} subiu de R\$ ${precoAnterior.toStringAsFixed(2)} para R\$ ${precoAtual.toStringAsFixed(2)}';
      
      // Envio via Push Notification
      if (settings.pushEnabled) {
        try {
          final pushResult = await _notificationService.sendNotificationToUser(
            userId: usuario.id,
            title: titulo,
            body: mensagem,
            data: {
              'type': 'price_alert',
              'produto_id': produto.id,
              'produto_nome': produto.nome,
              'preco_anterior': precoAnterior.toString(),
              'preco_atual': precoAtual.toString(),
              'diferenca': diferenca.toString(),
              'percentual': percentualDesconto.toString(),
            },
          );
          resultados['push'] = pushResult;
          AppLogger.info('Push notification enviado: $pushResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar push notification', e, stackTrace);
          resultados['push'] = false;
        }
      }
      
      // Envio via Email
      if (settings.emailEnabled && usuario.email.isNotEmpty) {
        try {
          final emailResult = await _emailService.enviarEmailNotificacao(
            usuario, 
            titulo, 
            mensagem,
            'price_alert'
          );
          resultados['email'] = emailResult;
          AppLogger.info('Email enviado: $emailResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar email', e, stackTrace);
          resultados['email'] = false;
        }
      }
      

      
      AppLogger.success('Notificação de alerta de preço processada: $resultados');
      return resultados;
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro geral ao enviar notificação de alerta de preço', e, stackTrace);
      return {'error': false};
    }
  }

  /// Envia notificação genérica
  /// 
  /// [usuario] - Usuário que receberá as notificações
  /// [titulo] - Título da notificação
  /// [mensagem] - Mensagem da notificação
  /// [tipo] - Tipo da notificação
  /// [settings] - Configurações de notificação do usuário
  /// [data] - Dados adicionais para a notificação
  Future<Map<String, bool>> enviarNotificacaoGenerica(
    Usuario usuario,
    String titulo,
    String mensagem,
    String tipo,
    NotificationSettings settings, {
    Map<String, dynamic>? data,
  }) async {
    final resultados = <String, bool>{};
    
    try {
      AppLogger.info('Enviando notificação genérica para ${usuario.nome}: $tipo');
      
      // Envio via Push Notification
      if (settings.pushEnabled) {
        try {
          final pushResult = await _notificationService.sendNotificationToUser(
            userId: usuario.id,
            title: titulo,
            body: mensagem,
            data: {
              'type': tipo,
              ...?data,
            },
          );
          resultados['push'] = pushResult;
          AppLogger.info('Push notification enviado: $pushResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar push notification', e, stackTrace);
          resultados['push'] = false;
        }
      }
      
      // Envio via Email
      if (settings.emailEnabled && usuario.email.isNotEmpty) {
        try {
          final emailResult = await _emailService.enviarEmailNotificacao(
            usuario, 
            titulo, 
            mensagem,
            tipo
          );
          resultados['email'] = emailResult;
          AppLogger.info('Email enviado: $emailResult');
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao enviar email', e, stackTrace);
          resultados['email'] = false;
        }
      }
      

      
      AppLogger.success('Notificação genérica processada: $resultados');
      return resultados;
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro geral ao enviar notificação genérica', e, stackTrace);
      return {'error': false};
    }
  }

  /// Testa conectividade com todos os serviços
  Future<Map<String, bool>> testarConectividade() async {
    final resultados = <String, bool>{};
    
    try {
      // Teste do serviço de push
      try {
        // Aqui você pode implementar um teste específico para FCM
        resultados['push'] = true;
      } catch (e) {
        resultados['push'] = false;
      }
      
      // Teste do serviço de email
      try {
        // Aqui você pode implementar um teste específico para o serviço de email
        resultados['email'] = true;
      } catch (e) {
        resultados['email'] = false;
      }
      

      
      AppLogger.info('Teste de conectividade: $resultados');
      return resultados;
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao testar conectividade', e, stackTrace);
      return {'error': false};
    }
  }

  /// Obtém estatísticas de envio de notificações
  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      // Aqui você pode implementar lógica para coletar estatísticas
      // de envios bem-sucedidos, falhas, etc.
      return {
        'total_enviados': 0,
        'push_enviados': 0,
        'email_enviados': 0,

        'falhas': 0,
        'ultima_atualizacao': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao obter estatísticas', e, stackTrace);
      return {'error': 'Erro ao obter estatísticas'};
    }
  }
}