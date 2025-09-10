import '../models/usuario.dart';
import '../datasources/firestore_auth_service.dart';

/// Interface do repositório de usuário
/// 
/// Define os contratos para operações de usuário,
/// permitindo diferentes implementações (Firestore, mock, etc.)
abstract class UserRepository {
  /// Registra um novo usuário
  Future<Usuario> registrarUsuario({
    required String nome,
    required String email,
    required String whatsapp,
    required String senha,
  });

  /// Faz login do usuário
  Future<Usuario> fazerLogin(String email, String senha);

  /// Obtém o usuário logado
  Future<Usuario?> getUsuarioLogado();

  /// Faz logout do usuário
  Future<void> fazerLogout();

  /// Atualiza dados do usuário
  Future<void> atualizarUsuario(String userId, Map<String, dynamic> dados);

  /// Busca usuário por ID
  Future<Usuario?> getUsuarioPorId(String userId);

  /// Envia email de recuperação
  Future<void> enviarEmailRecuperacao(String email);
}

/// Implementação do repositório de usuário usando Firestore
/// 
/// Implementa a interface UserRepository usando o FirestoreAuthService
class FirestoreUserRepository implements UserRepository {
  final FirestoreAuthService _authService;

  FirestoreUserRepository(this._authService);

  @override
  Future<Usuario> registrarUsuario({
    required String nome,
    required String email,
    required String whatsapp,
    required String senha,
  }) async {
    return await _authService.registrarUsuario(
      nome: nome,
      email: email,
      whatsapp: whatsapp,
      senha: senha,
    );
  }

  @override
  Future<Usuario> fazerLogin(String email, String senha) async {
    return await _authService.fazerLogin(email, senha);
  }

  @override
  Future<Usuario?> getUsuarioLogado() async {
    return await _authService.getUsuarioLogado();
  }

  @override
  Future<void> fazerLogout() async {
    await _authService.fazerLogout();
  }

  @override
  Future<void> atualizarUsuario(String userId, Map<String, dynamic> dados) async {
    await _authService.atualizarUsuario(userId, dados);
  }

  @override
  Future<Usuario?> getUsuarioPorId(String userId) async {
    return await _authService.getUsuarioPorId(userId);
  }

  @override
  Future<void> enviarEmailRecuperacao(String email) async {
    await _authService.enviarEmailRecuperacao(email);
  }
}