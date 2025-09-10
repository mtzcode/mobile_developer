import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../datasources/firestore_auth_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreAuthService _authService = FirestoreAuthService();
  Usuario? _usuarioLogado;
  bool _isLoading = false;
  bool _isInitialized = false;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _usuarioLogado != null;
  bool get isInitialized => _isInitialized;

  // Carregar dados do usuário logado
  Future<void> carregarUsuarioLogado() async {
    if (_isLoading) return; // Evita chamadas múltiplas
    
    _isLoading = true;
    if (!_isInitialized) {
      notifyListeners();
    }
    
    try {
      _usuarioLogado = await _authService.getUsuarioLogado();
    } catch (e) {
      _usuarioLogado = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Fazer logout
  Future<void> fazerLogout() async {
    try {
      await _authService.fazerLogout();
      _usuarioLogado = null;
      notifyListeners();
    } catch (e) {
      // Ignorar erro no logout
    }
  }

  // Atualizar dados do usuário
  Future<void> atualizarDadosUsuario(Map<String, dynamic> dados) async {
    if (_usuarioLogado == null) return;
    
    try {
      await _authService.atualizarUsuario(_usuarioLogado!.id, dados);
      
      // Recarregar dados do usuário
      await carregarUsuarioLogado();
    } catch (e) {
      rethrow;
    }
  }

  // Adicionar novo endereço à lista de endereços do usuário
  Future<void> adicionarEndereco(Map<String, dynamic> novoEndereco) async {
    if (_usuarioLogado == null) return;
    
    try {
      // Criar nova lista de endereços
      List<Map<String, dynamic>> enderecosAtualizados = [];
      if (_usuarioLogado!.enderecos != null) {
        enderecosAtualizados.addAll(_usuarioLogado!.enderecos!);
      }
      
      // Adicionar novo endereço à lista
      enderecosAtualizados.add(novoEndereco);
      
      // Salvar no Firestore
      await _authService.atualizarUsuario(_usuarioLogado!.id, {
        'enderecos': enderecosAtualizados,
        'dataAtualizacao': DateTime.now().toIso8601String(),
      });
      
      // Recarregar dados do usuário para refletir as mudanças
      await carregarUsuarioLogado();
    } catch (e) {
      rethrow;
    }
  }

  // Carregar usuário (alias para carregarUsuarioLogado)
  Future<void> carregarUsuario() async {
    await carregarUsuarioLogado();
  }
}