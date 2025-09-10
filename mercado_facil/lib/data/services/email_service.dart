import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/logger.dart';
import '../models/usuario.dart';
import '../models/produto.dart';
import '../models/carrinho_item.dart';

/// Serviço responsável pelo envio de emails de notificação
/// 
/// Este serviço integra com APIs de email (SendGrid, Mailgun, etc.)
/// para enviar notificações por email baseadas nas preferências do usuário.
class EmailService {
  static const String _baseUrl = 'https://api.sendgrid.v3';
  static const String _apiKey = 'SG.YOUR_SENDGRID_API_KEY'; // Configurar no .env
  static const String _fromEmail = 'noreply@mercadofacil.com';
  static const String _fromName = 'Mercado Fácil';

  /// Envia email de produto favorito em promoção
  /// 
  /// [usuario] - Usuário que receberá o email
  /// [produto] - Produto que entrou em promoção
  Future<bool> enviarEmailFavoritoPromocao(Usuario usuario, Produto produto) async {
    try {
      AppLogger.info('Enviando email de favorito em promoção para ${usuario.email}');
      
      final subject = '🔥 Seu produto favorito está em oferta!';
      final htmlContent = _buildFavoritoPromocaoHtml(usuario, produto);
      
      return await _sendEmail(
        to: usuario.email,
        subject: subject,
        htmlContent: htmlContent,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar email de favorito em promoção', e, stackTrace);
      return false;
    }
  }

  /// Envia email de lembrete de carrinho abandonado
  /// 
  /// [usuario] - Usuário que receberá o email
  /// [itensCarrinho] - Itens no carrinho abandonado
  /// [totalCarrinho] - Valor total do carrinho
  Future<bool> enviarEmailLembreteCarrinho(
    Usuario usuario, 
    List<CarrinhoItem> itensCarrinho, 
    double totalCarrinho
  ) async {
    try {
      AppLogger.info('Enviando email de lembrete de carrinho para ${usuario.email}');
      
      final subject = '🛒 Você esqueceu alguns itens no seu carrinho';
      final htmlContent = _buildLembreteCarrinhoHtml(usuario, itensCarrinho, totalCarrinho);
      
      return await _sendEmail(
        to: usuario.email,
        subject: subject,
        htmlContent: htmlContent,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar email de lembrete de carrinho', e, stackTrace);
      return false;
    }
  }

  /// Envia email de novo produto disponível
  /// 
  /// [usuario] - Usuário que receberá o email
  /// [produto] - Novo produto disponível
  /// [categoria] - Categoria do produto
  Future<bool> enviarEmailNovoProduto(Usuario usuario, Produto produto, String categoria) async {
    try {
      AppLogger.info('Enviando email de novo produto para ${usuario.email}');
      
      final subject = '🆕 Novo produto disponível: ${produto.nome}';
      final htmlContent = _buildNovoProdutoHtml(usuario, produto, categoria);
      
      return await _sendEmail(
        to: usuario.email,
        subject: subject,
        htmlContent: htmlContent,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar email de novo produto', e, stackTrace);
      return false;
    }
  }

  /// Envia email genérico de notificação
  /// 
  /// [usuario] - Usuário que receberá o email
  /// [titulo] - Título da notificação
  /// [mensagem] - Mensagem da notificação
  /// [tipo] - Tipo da notificação para personalização
  Future<bool> enviarEmailNotificacao(
    Usuario usuario, 
    String titulo, 
    String mensagem, 
    String tipo
  ) async {
    try {
      AppLogger.info('Enviando email de notificação para ${usuario.email}');
      
      final htmlContent = _buildNotificacaoGenericaHtml(usuario, titulo, mensagem, tipo);
      
      return await _sendEmail(
        to: usuario.email,
        subject: titulo,
        htmlContent: htmlContent,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar email de notificação', e, stackTrace);
      return false;
    }
  }

  /// Método privado para envio de email via SendGrid
  Future<bool> _sendEmail({
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mail/send'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': to}
              ],
              'subject': subject,
            }
          ],
          'from': {
            'email': _fromEmail,
            'name': _fromName,
          },
          'content': [
            {
              'type': 'text/html',
              'value': htmlContent,
            }
          ],
        }),
      );

      if (response.statusCode == 202) {
        AppLogger.success('Email enviado com sucesso para $to');
        return true;
      } else {
        AppLogger.error('Falha ao enviar email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro na requisição de email', e, stackTrace);
      return false;
    }
  }

  /// Constrói HTML para email de favorito em promoção
  String _buildFavoritoPromocaoHtml(Usuario usuario, Produto produto) {
    final precoOriginal = produto.preco.toStringAsFixed(2);
    final precoPromocional = produto.precoPromocional?.toStringAsFixed(2) ?? precoOriginal;
    final desconto = produto.precoPromocional != null 
        ? ((produto.preco - produto.precoPromocional!) / produto.preco * 100).round()
        : 0;

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Produto Favorito em Oferta</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="margin: 0; font-size: 28px;">🔥 Oferta Especial!</h1>
        <p style="margin: 10px 0 0 0; font-size: 16px;">Seu produto favorito está com desconto</p>
    </div>
    
    <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
        <p style="font-size: 18px; margin-bottom: 20px;">Olá, <strong>${usuario.nome}</strong>!</p>
        
        <div style="background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #28a745; margin: 20px 0;">
            <h2 style="color: #28a745; margin-top: 0;">${produto.nome}</h2>
            <div style="display: flex; align-items: center; gap: 15px; margin: 15px 0;">
                <img src="${produto.imagemUrl}" alt="${produto.nome}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 8px;">
                <div>
                    <p style="margin: 5px 0; color: #666;">De: <span style="text-decoration: line-through;">R\$ $precoOriginal</span></p>
                    <p style="margin: 5px 0; font-size: 24px; font-weight: bold; color: #28a745;">Por: R\$ $precoPromocional</p>
                    ${desconto > 0 ? '<p style="margin: 5px 0; background: #dc3545; color: white; padding: 5px 10px; border-radius: 15px; display: inline-block; font-size: 14px;">$desconto% OFF</p>' : ''}
                </div>
            </div>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="https://mercadofacil.com/produto/${produto.id}" style="background: #28a745; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Ver Produto</a>
        </div>
        
        <p style="font-size: 14px; color: #666; text-align: center; margin-top: 30px;">
            Esta oferta é por tempo limitado. Não perca!
        </p>
    </div>
    
    <div style="text-align: center; margin-top: 20px; font-size: 12px; color: #999;">
        <p>Mercado Fácil - Sempre os melhores preços</p>
        <p>Para cancelar estas notificações, <a href="#" style="color: #667eea;">clique aqui</a></p>
    </div>
</body>
</html>
''';
  }

  /// Constrói HTML para email de lembrete de carrinho
  String _buildLembreteCarrinhoHtml(Usuario usuario, List<CarrinhoItem> itens, double total) {
    final itensHtml = itens.map((item) => '''
        <div style="display: flex; align-items: center; gap: 15px; padding: 15px; border-bottom: 1px solid #eee;">
            <img src="${item.produto.imagemUrl}" alt="${item.produto.nome}" style="width: 60px; height: 60px; object-fit: cover; border-radius: 6px;">
            <div style="flex: 1;">
                <h4 style="margin: 0 0 5px 0; color: #333;">${item.produto.nome}</h4>
                <p style="margin: 0; color: #666; font-size: 14px;">Quantidade: ${item.quantidade}</p>
                <p style="margin: 5px 0 0 0; font-weight: bold; color: #28a745;">R\$ ${item.subtotal.toStringAsFixed(2)}</p>
            </div>
        </div>
    ''').join('');

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lembrete de Carrinho</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="margin: 0; font-size: 28px;">🛒 Não esqueça!</h1>
        <p style="margin: 10px 0 0 0; font-size: 16px;">Você tem itens esperando no seu carrinho</p>
    </div>
    
    <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
        <p style="font-size: 18px; margin-bottom: 20px;">Olá, <strong>${usuario.nome}</strong>!</p>
        
        <p style="margin-bottom: 25px;">Você adicionou alguns produtos ao seu carrinho, mas ainda não finalizou a compra. Que tal aproveitar agora?</p>
        
        <div style="background: white; border-radius: 8px; overflow: hidden; margin: 20px 0;">
            <div style="background: #667eea; color: white; padding: 15px; font-weight: bold;">Seus itens salvos:</div>
            $itensHtml
            <div style="padding: 20px; background: #f8f9fa; text-align: right;">
                <p style="margin: 0; font-size: 18px; font-weight: bold; color: #333;">Total: R\$ ${total.toStringAsFixed(2)}</p>
            </div>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="https://mercadofacil.com/carrinho" style="background: #28a745; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Finalizar Compra</a>
        </div>
        
        <p style="font-size: 14px; color: #666; text-align: center; margin-top: 30px;">
            Seus itens ficam salvos por 7 dias. Não perca tempo!
        </p>
    </div>
    
    <div style="text-align: center; margin-top: 20px; font-size: 12px; color: #999;">
        <p>Mercado Fácil - Sempre os melhores preços</p>
        <p>Para cancelar estas notificações, <a href="#" style="color: #667eea;">clique aqui</a></p>
    </div>
</body>
</html>
''';
  }

  /// Constrói HTML para email de novo produto
  String _buildNovoProdutoHtml(Usuario usuario, Produto produto, String categoria) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Novo Produto Disponível</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="margin: 0; font-size: 28px;">🆕 Novidade!</h1>
        <p style="margin: 10px 0 0 0; font-size: 16px;">Novo produto disponível em $categoria</p>
    </div>
    
    <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
        <p style="font-size: 18px; margin-bottom: 20px;">Olá, <strong>${usuario.nome}</strong>!</p>
        
        <p style="margin-bottom: 25px;">Temos uma novidade especial para você na categoria <strong>$categoria</strong>:</p>
        
        <div style="background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #4facfe; margin: 20px 0; text-align: center;">
            <img src="${produto.imagemUrl}" alt="${produto.nome}" style="width: 150px; height: 150px; object-fit: cover; border-radius: 8px; margin-bottom: 15px;">
            <h2 style="color: #4facfe; margin: 15px 0;">${produto.nome}</h2>
            <p style="margin: 10px 0; color: #666; font-size: 16px;">${produto.descricao ?? 'Produto de alta qualidade'}</p>
            <p style="margin: 15px 0; font-size: 24px; font-weight: bold; color: #28a745;">R\$ ${produto.preco.toStringAsFixed(2)}</p>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="https://mercadofacil.com/produto/${produto.id}" style="background: #4facfe; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Ver Produto</a>
        </div>
        
        <p style="font-size: 14px; color: #666; text-align: center; margin-top: 30px;">
            Seja um dos primeiros a experimentar!
        </p>
    </div>
    
    <div style="text-align: center; margin-top: 20px; font-size: 12px; color: #999;">
        <p>Mercado Fácil - Sempre os melhores preços</p>
        <p>Para cancelar estas notificações, <a href="#" style="color: #667eea;">clique aqui</a></p>
    </div>
</body>
</html>
''';
  }

  /// Constrói HTML para notificação genérica
  String _buildNotificacaoGenericaHtml(Usuario usuario, String titulo, String mensagem, String tipo) {
    final emoji = _getEmojiForType(tipo);
    final cor = _getColorForType(tipo);
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$titulo</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: $cor; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="margin: 0; font-size: 28px;">$emoji $titulo</h1>
    </div>
    
    <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
        <p style="font-size: 18px; margin-bottom: 20px;">Olá, <strong>${usuario.nome}</strong>!</p>
        
        <div style="background: white; padding: 20px; border-radius: 8px; border-left: 4px solid $cor; margin: 20px 0;">
            <p style="margin: 0; font-size: 16px; line-height: 1.6;">$mensagem</p>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="https://mercadofacil.com" style="background: $cor; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Acessar App</a>
        </div>
    </div>
    
    <div style="text-align: center; margin-top: 20px; font-size: 12px; color: #999;">
        <p>Mercado Fácil - Sempre os melhores preços</p>
        <p>Para cancelar estas notificações, <a href="#" style="color: #667eea;">clique aqui</a></p>
    </div>
</body>
</html>
''';
  }

  /// Retorna emoji baseado no tipo de notificação
  String _getEmojiForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'order':
      case 'pedido':
        return '📦';
      case 'delivery':
      case 'entrega':
        return '🚚';
      case 'promotion':
      case 'promocao':
        return '🔥';
      case 'system':
      case 'sistema':
        return '⚙️';
      default:
        return '📢';
    }
  }

  /// Retorna cor baseada no tipo de notificação
  String _getColorForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'order':
      case 'pedido':
        return 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
      case 'delivery':
      case 'entrega':
        return 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)';
      case 'promotion':
      case 'promocao':
        return 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)';
      case 'system':
      case 'sistema':
        return 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)';
      default:
        return 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
    }
  }
}