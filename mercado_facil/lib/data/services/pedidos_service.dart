import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido.dart';
import '../models/carrinho_item.dart';
import '../../core/utils/logger.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/error/error_handler.dart';

class PedidosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _colecao = 'pedidos';

  // Criar novo pedido
  Future<String> criarPedido({
    required String usuarioId,
    required List<CarrinhoItem> itens,
    required Map<String, dynamic> enderecoEntrega,
    required String metodoPagamento,
    String? observacoes,
    double taxaEntrega = 5.0, // Taxa fixa por enquanto
  }) async {
    return ErrorHandler.executeWithRetry(
      operation: () async {
        AppLogger.order('Iniciando criação de pedido para usuário: $usuarioId');
        AppLogger.debug('Detalhes do pedido', {
          'usuarioId': usuarioId,
          'quantidadeItens': itens.length,
          'metodoPagamento': metodoPagamento,
          'taxaEntrega': taxaEntrega,
        });
        
        // Validar dados de entrada
        if (itens.isEmpty) {
          throw AppException.validationError(
            message: 'Carrinho vazio',
            userMessage: 'Adicione produtos ao carrinho antes de finalizar o pedido',
          );
        }

        if (usuarioId.isEmpty) {
          throw AppException.validationError(
            message: 'ID do usuário inválido',
            userMessage: 'Erro de autenticação. Faça login novamente',
          );
        }

        // Calcular totais
        final subtotal = itens.fold(0.0, (soma, item) => soma + item.subtotal);
        final total = subtotal + taxaEntrega;

        AppLogger.debug('Cálculos do pedido', {
          'subtotal': subtotal,
          'taxaEntrega': taxaEntrega,
          'total': total,
        });

        // Preparar dados do pedido
        final dadosPedido = {
          'usuarioId': usuarioId,
          'itens': itens.map((item) => {
            'produto': item.produto.toMap(),
            'quantidade': item.quantidade,
          }).toList(),
          'subtotal': subtotal,
          'taxaEntrega': taxaEntrega,
          'total': total,
          'enderecoEntrega': enderecoEntrega,
          'observacoes': observacoes,
          'status': StatusPedido.pendente.name,
          'dataCriacao': DateTime.now().toIso8601String(),
          'metodoPagamento': metodoPagamento,
        };

        // Criar documento do pedido
        AppLogger.api('Criando documento no Firestore');
        final docRef = await _firestore.collection(_colecao).add(dadosPedido);
        
        AppLogger.order('Pedido criado com sucesso', 'ID: ${docRef.id}');
        return docRef.id;
      },
      operationName: 'Criação de pedido',
      maxRetries: 2,
    );
  }

  // Buscar pedidos do usuário
  Future<List<Pedido>> buscarPedidosUsuario(String usuarioId) async {
    return ErrorHandler.executeWithRetry(
      operation: () async {
        AppLogger.order('Buscando pedidos do usuário: $usuarioId');
        
        if (usuarioId.isEmpty) {
          throw AppException.validationError(
            message: 'ID do usuário inválido',
            userMessage: 'Erro de autenticação. Faça login novamente',
          );
        }

        final querySnapshot = await _firestore
            .collection(_colecao)
            .where('usuarioId', isEqualTo: usuarioId)
            .orderBy('dataCriacao', descending: true)
            .get();

        final pedidos = querySnapshot.docs.map((doc) {
          return Pedido.fromMap(doc.id, doc.data());
        }).toList();

        AppLogger.order('Pedidos encontrados', 'Quantidade: ${pedidos.length}');
        return pedidos;
      },
      operationName: 'Busca de pedidos do usuário',
      maxRetries: 3,
    );
  }

  // Buscar pedido específico
  Future<Pedido?> buscarPedido(String pedidoId) async {
    return ErrorHandler.executeWithRetry(
      operation: () async {
        AppLogger.order('Buscando pedido específico: $pedidoId');
        
        if (pedidoId.isEmpty) {
          throw AppException.validationError(
            message: 'ID do pedido inválido',
            userMessage: 'Pedido não encontrado',
          );
        }

        final doc = await _firestore.collection(_colecao).doc(pedidoId).get();
        if (doc.exists) {
          final pedido = Pedido.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          AppLogger.order('Pedido encontrado', 'ID: $pedidoId');
          return pedido;
        } else {
          throw AppException.dataNotFound(
            message: 'Pedido não encontrado no Firestore',
            userMessage: 'Pedido não encontrado',
            resource: 'pedido',
            originalError: 'Documento não existe: $pedidoId',
          );
        }
      },
      operationName: 'Busca de pedido específico',
      maxRetries: 2,
    );
  }

  // Atualizar status do pedido
  Future<void> atualizarStatusPedido(String pedidoId, StatusPedido novoStatus) async {
    return ErrorHandler.executeWithRetry(
      operation: () async {
        AppLogger.order('Atualizando status do pedido', 'ID: $pedidoId, Novo status: ${novoStatus.name}');
        
        if (pedidoId.isEmpty) {
          throw AppException.validationError(
            message: 'ID do pedido inválido',
            userMessage: 'Pedido não encontrado',
          );
        }

        final updates = <String, dynamic>{
          'status': novoStatus.name,
        };

        // Adicionar timestamps específicos baseados no status
        switch (novoStatus) {
          case StatusPedido.confirmado:
            updates['dataConfirmacao'] = DateTime.now().toIso8601String();
            break;
          case StatusPedido.entregue:
            updates['dataEntrega'] = DateTime.now().toIso8601String();
            break;
          default:
            break;
        }

        await _firestore.collection(_colecao).doc(pedidoId).update(updates);
        AppLogger.order('Status atualizado com sucesso', 'ID: $pedidoId, Status: ${novoStatus.name}');
      },
      operationName: 'Atualização de status do pedido',
      maxRetries: 2,
    );
  }

  // Cancelar pedido
  Future<void> cancelarPedido(String pedidoId) async {
    return ErrorHandler.executeWithRetry(
      operation: () async {
        AppLogger.order('Cancelando pedido: $pedidoId');
        
        if (pedidoId.isEmpty) {
          throw AppException.validationError(
            message: 'ID do pedido inválido',
            userMessage: 'Pedido não encontrado',
          );
        }

        await _firestore.collection(_colecao).doc(pedidoId).update({
          'status': StatusPedido.cancelado.name,
        });
        AppLogger.order('Pedido cancelado com sucesso', 'ID: $pedidoId');
      },
      operationName: 'Cancelamento de pedido',
      maxRetries: 2,
    );
  }

  // Adicionar código de rastreamento
  Future<void> adicionarCodigoRastreamento(String pedidoId, String codigo) async {
    return ErrorHandler.executeWithRetry(
      operation: () async {
        AppLogger.order('Adicionando código de rastreamento', 'ID: $pedidoId, Código: $codigo');
        
        if (pedidoId.isEmpty) {
          throw AppException.validationError(
            message: 'ID do pedido inválido',
            userMessage: 'Pedido não encontrado',
          );
        }

        if (codigo.isEmpty) {
          throw AppException.validationError(
            message: 'Código de rastreamento inválido',
            userMessage: 'Código de rastreamento é obrigatório',
          );
        }

        await _firestore.collection(_colecao).doc(pedidoId).update({
          'codigoRastreamento': codigo,
        });
        AppLogger.order('Código de rastreamento adicionado', 'ID: $pedidoId, Código: $codigo');
      },
      operationName: 'Adição de código de rastreamento',
      maxRetries: 2,
    );
  }

  // Stream de pedidos do usuário (tempo real)
  Stream<List<Pedido>> pedidosUsuarioStream(String usuarioId) {
    AppLogger.order('Iniciando stream de pedidos', 'Usuário: $usuarioId');
    
    return _firestore
        .collection(_colecao)
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) {
      final pedidos = snapshot.docs.map((doc) {
        return Pedido.fromMap(doc.id, doc.data());
      }).toList();
      
      AppLogger.debug('Stream de pedidos atualizado', 'Quantidade: ${pedidos.length}');
      return pedidos;
    });
  }

  // Stream de pedido específico (tempo real)
  Stream<Pedido?> pedidoStream(String pedidoId) {
    AppLogger.order('Iniciando stream de pedido específico', 'ID: $pedidoId');
    
    return _firestore
        .collection(_colecao)
        .doc(pedidoId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final pedido = Pedido.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        AppLogger.debug('Stream de pedido atualizado', 'ID: $pedidoId');
        return pedido;
      }
      return null;
    });
  }

  // Buscar pedidos por status
  Future<List<Pedido>> buscarPedidosPorStatus(String usuarioId, StatusPedido status) async {
    AppLogger.order('Buscando pedidos por status', 'Usuário: $usuarioId, Status: ${status.name}');
    
    try {
      final querySnapshot = await _firestore
          .collection(_colecao)
          .where('usuarioId', isEqualTo: usuarioId)
          .where('status', isEqualTo: status.name)
          .orderBy('dataCriacao', descending: true)
          .get();

      final pedidos = querySnapshot.docs.map((doc) {
        return Pedido.fromMap(doc.id, doc.data());
      }).toList();

      AppLogger.order('Pedidos por status encontrados', 'Quantidade: ${pedidos.length}, Status: ${status.name}');
      return pedidos;
    } catch (e, stackTrace) {
      AppLogger.failure('Busca de pedidos por status', 'Erro ao buscar pedidos', e, stackTrace);
      return [];
    }
  }

  // Buscar pedidos em andamento
  Future<List<Pedido>> buscarPedidosEmAndamento(String usuarioId) async {
    AppLogger.order('Buscando pedidos em andamento', 'Usuário: $usuarioId');
    
    try {
      final querySnapshot = await _firestore
          .collection(_colecao)
          .where('usuarioId', isEqualTo: usuarioId)
          .where('status', whereIn: [
            StatusPedido.confirmado.name,
            StatusPedido.emPreparacao.name,
            StatusPedido.emEntrega.name,
          ])
          .orderBy('dataCriacao', descending: true)
          .get();

      final pedidos = querySnapshot.docs.map((doc) {
        return Pedido.fromMap(doc.id, doc.data());
      }).toList();

      AppLogger.order('Pedidos em andamento encontrados', 'Quantidade: ${pedidos.length}');
      return pedidos;
    } catch (e, stackTrace) {
      AppLogger.failure('Busca de pedidos em andamento', 'Erro ao buscar pedidos', e, stackTrace);
      return [];
    }
  }

  // Estatísticas do usuário
  Future<Map<String, dynamic>> estatisticasUsuario(String usuarioId) async {
    AppLogger.order('Buscando estatísticas do usuário: $usuarioId');
    
    try {
      final querySnapshot = await _firestore
          .collection(_colecao)
          .where('usuarioId', isEqualTo: usuarioId)
          .get();

      final pedidos = querySnapshot.docs.map((doc) {
        return Pedido.fromMap(doc.id, doc.data());
      }).toList();

      int totalPedidos = pedidos.length;
      int pedidosPendentes = pedidos.where((p) => p.status == StatusPedido.pendente).length;
      int pedidosEmAndamento = pedidos.where((p) => p.estaEmAndamento).length;
      int pedidosEntregues = pedidos.where((p) => p.foiEntregue).length;
      int pedidosCancelados = pedidos.where((p) => p.foiCancelado).length;
      double valorTotal = pedidos.where((p) => p.foiEntregue).fold(0.0, (soma, p) => soma + p.total);

      final estatisticas = {
        'totalPedidos': totalPedidos,
        'pedidosPendentes': pedidosPendentes,
        'pedidosEmAndamento': pedidosEmAndamento,
        'pedidosEntregues': pedidosEntregues,
        'pedidosCancelados': pedidosCancelados,
        'valorTotal': valorTotal,
      };

      AppLogger.order('Estatísticas calculadas', 'Total: $totalPedidos, Valor: R\$ ${valorTotal.toStringAsFixed(2)}');
      return estatisticas;
    } catch (e, stackTrace) {
      AppLogger.failure('Cálculo de estatísticas', 'Erro ao calcular estatísticas', e, stackTrace);
      return {
        'totalPedidos': 0,
        'pedidosPendentes': 0,
        'pedidosEmAndamento': 0,
        'pedidosEntregues': 0,
        'pedidosCancelados': 0,
        'valorTotal': 0.0,
      };
    }
  }
}