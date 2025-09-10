import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario.dart';
import '../datasources/firestore_auth_service.dart';

// Estado do usuário
class UserState {
  final Usuario? usuario;
  final bool isLoading;
  final bool isInitialized;
  final String? erro;

  const UserState({
    this.usuario,
    this.isLoading = false,
    this.isInitialized = false,
    this.erro,
  });

  bool get isLoggedIn => usuario != null;

  UserState copyWith({
    Usuario? usuario,
    bool? isLoading,
    bool? isInitialized,
    String? erro,
  }) {
    return UserState(
      usuario: usuario ?? this.usuario,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      erro: erro ?? this.erro,
    );
  }
}

// Notifier do usuário
class UserNotifier extends StateNotifier<UserState> {
  final FirestoreAuthService _authService;

  UserNotifier(this._authService) : super(const UserState());

  // Carregar dados do usuário logado
  Future<void> carregarUsuarioLogado() async {
    if (state.isLoading) return; // Evita chamadas múltiplas
    
    state = state.copyWith(isLoading: true, erro: null);
    
    try {
      final usuario = await _authService.getUsuarioLogado();
      state = state.copyWith(
        usuario: usuario,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        usuario: null,
        isLoading: false,
        isInitialized: true,
        erro: e.toString(),
      );
    }
  }

  // Fazer logout
  Future<void> fazerLogout() async {
    try {
      await _authService.fazerLogout();
      state = state.copyWith(usuario: null, erro: null);
    } catch (e) {
      state = state.copyWith(erro: e.toString());
    }
  }

  // Atualizar dados do usuário
  Future<void> atualizarDadosUsuario(Map<String, dynamic> dados) async {
    if (state.usuario == null) return;
    
    state = state.copyWith(isLoading: true, erro: null);
    
    try {
      await _authService.atualizarUsuario(state.usuario!.id, dados);
      // Recarregar dados do usuário após atualização
      await carregarUsuarioLogado();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: e.toString(),
      );
    }
  }

  // Limpar erro
  void limparErro() {
    state = state.copyWith(erro: null);
  }
}

// Provider do serviço de autenticação
final authServiceProvider = Provider<FirestoreAuthService>((ref) {
  return FirestoreAuthService();
});

// Provider do notifier do usuário
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserNotifier(authService);
});

// Providers derivados para facilitar o acesso
final usuarioLogadoProvider = Provider<Usuario?>((ref) {
  return ref.watch(userProvider).usuario;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoggedIn;
});

final isLoadingUserProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

final isUserInitializedProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isInitialized;
});