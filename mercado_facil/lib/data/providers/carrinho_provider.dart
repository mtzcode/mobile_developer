import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/carrinho_item.dart';
import '../models/produto.dart';
import '../../core/utils/logger.dart';

class CarrinhoProvider extends ChangeNotifier {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _colecao = 'carrinhos';

  List<CarrinhoItem> _itens = [];
  bool _carregado = false;

  CarrinhoProvider({required this.userId}) {
    // Carregar carrinho automaticamente quando o provider é criado
    if (userId.isNotEmpty) {
      AppLogger.cart('Inicializando CarrinhoProvider para usuário: $userId');
      carregarCarrinho();
    } else {
      AppLogger.cart('CarrinhoProvider inicializado sem usuário');
      _carregado = true;
    }
  }

  List<CarrinhoItem> get itens => List.unmodifiable(_itens);
  double get total => _itens.fold(0, (soma, item) => soma + item.subtotal);
  int get quantidadeTotal => _itens.fold(0, (soma, item) => soma + item.quantidade);
  bool get carregado => _carregado;

  // Buscar carrinho do Firestore (uma vez)
  Future<void> carregarCarrinho() async {
    if (userId.isEmpty) {
      AppLogger.cart('Tentativa de carregar carrinho sem userId');
      _itens = [];
      _carregado = true;
      notifyListeners();
      return;
    }
    
    AppLogger.cart('Carregando carrinho do Firestore', 'Usuário: $userId');
    
    try {
      final doc = await _firestore.collection(_colecao).doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final itensFirestore = data['itens'] as List<dynamic>? ?? [];
        _itens = itensFirestore.map((item) => CarrinhoItem(
          produto: Produto.fromMap(item['produto']),
          quantidade: item['quantidade'] ?? 1,
        )).toList();
        AppLogger.cart('Carrinho carregado com sucesso', 'Quantidade de itens: ${_itens.length}');
      } else {
        _itens = [];
        AppLogger.cart('Carrinho não encontrado no Firestore', 'Usuário: $userId');
      }
    } catch (e, stackTrace) {
      AppLogger.failure('Carregamento de carrinho', 'Erro ao carregar carrinho do Firestore', e, stackTrace);
      _itens = [];
    }
    _carregado = true;
    notifyListeners();
  }

  // Stream do carrinho (tempo real) - DESABILITADO para evitar conflitos
  // Usando apenas estado local para melhor performance
  Stream<List<CarrinhoItem>> carrinhoStream() {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    
    // Retorna stream do estado local em vez do Firestore
    return Stream.value(_itens);
  }

  Future<void> _salvarCarrinho() async {
    if (userId.isEmpty) {
      AppLogger.cart('Tentativa de salvar carrinho sem userId');
      return;
    }
    
    try {
      final itensFirestore = _itens.map((item) => {
        'produto': item.produto.toMap(),
        'quantidade': item.quantidade,
      }).toList();
      
      await _firestore.collection(_colecao).doc(userId).set({
        'itens': itensFirestore,
      });
      
      AppLogger.cart('Carrinho salvo no Firestore', 'Usuário: $userId, Itens: ${_itens.length}');
    } catch (e, stackTrace) {
      AppLogger.failure('Salvamento de carrinho', 'Erro ao salvar carrinho no Firestore', e, stackTrace);
    }
  }

  void adicionarProduto(Produto produto) {
    if (userId.isEmpty) {
      AppLogger.cart('Tentativa de adicionar produto sem userId');
      return;
    }
    
    AppLogger.cart('Adicionando produto ao carrinho', 'Produto: ${produto.nome}, Usuário: $userId');
    
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);
    if (index >= 0) {
      _itens[index].quantidade++;
      AppLogger.cart('Quantidade atualizada', 'Produto: ${produto.nome}, Nova quantidade: ${_itens[index].quantidade}');
    } else {
      _itens.add(CarrinhoItem(produto: produto));
      AppLogger.cart('Novo produto adicionado', 'Produto: ${produto.nome}');
    }
    
    // Atualizar UI imediatamente
    notifyListeners();
    
    // Salvar no Firestore em background (sem aguardar)
    _salvarCarrinho();
  }

  void removerProduto(Produto produto) {
    if (userId.isEmpty) return;
    
    AppLogger.cart('Removendo produto do carrinho', 'Produto: ${produto.nome}, Usuário: $userId');
    
    _itens.removeWhere((item) => item.produto.id == produto.id);
    
    // Atualizar UI imediatamente
    notifyListeners();
    
    // Salvar no Firestore em background (sem aguardar)
    _salvarCarrinho();
  }

  void alterarQuantidade(Produto produto, int quantidade) {
    if (userId.isEmpty) return;
    
    AppLogger.cart('Alterando quantidade do produto', 'Produto: ${produto.nome}, Nova quantidade: $quantidade');
    
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);
    if (index >= 0) {
      if (quantidade <= 0) {
        _itens.removeAt(index);
        AppLogger.cart('Produto removido (quantidade zero)', 'Produto: ${produto.nome}');
      } else {
        _itens[index].quantidade = quantidade;
        AppLogger.cart('Quantidade alterada', 'Produto: ${produto.nome}, Quantidade: $quantidade');
      }
      
      // Atualizar UI imediatamente
      notifyListeners();
      
      // Salvar no Firestore em background (sem aguardar)
      _salvarCarrinho();
    }
  }

  void limparCarrinho() {
    if (userId.isEmpty) return;
    
    AppLogger.cart('Limpando carrinho', 'Usuário: $userId');
    
    _itens.clear();
    
    // Atualizar UI imediatamente
    notifyListeners();
    
    // Salvar no Firestore em background (sem aguardar)
    _salvarCarrinho();
  }
} 