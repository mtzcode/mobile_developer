import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/user_repository.dart';
import '../repositories/carrinho_repository.dart';
import '../repositories/pedidos_repository.dart';
import '../datasources/firestore_auth_service.dart';
import '../services/pedidos_service.dart';
import '../models/usuario.dart';
import '../models/carrinho_item.dart';
import '../models/pedido.dart';
import 'user_provider_riverpod.dart';
import 'carrinho_provider_riverpod.dart';
import 'pedidos_provider_riverpod.dart';

/// Configuração dos providers Riverpod
/// 
/// Este arquivo centraliza a configuração de injeção de dependências
/// para todos os repositórios e providers do sistema.

// ===== SERVIÇOS =====

/// Provider do Firebase Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider do serviço de autenticação
final firestoreAuthServiceProvider = Provider<FirestoreAuthService>((ref) {
  return FirestoreAuthService();
});

/// Provider do serviço de pedidos
final pedidosServiceProvider = Provider<PedidosService>((ref) {
  return PedidosService();
});

// ===== REPOSITÓRIOS =====

/// Provider do repositório de usuário
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final authService = ref.watch(firestoreAuthServiceProvider);
  return FirestoreUserRepository(authService);
});

/// Provider do repositório de carrinho
final carrinhoRepositoryProvider = Provider<CarrinhoRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreCarrinhoRepository(firestore);
});

/// Provider do repositório de pedidos
final pedidosRepositoryProvider = Provider<PedidosRepository>((ref) {
  final pedidosService = ref.watch(pedidosServiceProvider);
  return ServicePedidosRepository(pedidosService);
});

// ===== PROVIDERS RIVERPOD =====

/// Provider do notifier de usuário
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final authService = ref.watch(firestoreAuthServiceProvider);
  return UserNotifier(authService);
});

/// Provider do notifier de carrinho
final carrinhoProvider = StateNotifierProvider.family<CarrinhoNotifier, CarrinhoState, String>((ref, userId) {
  final repository = ref.watch(carrinhoRepositoryProvider);
  return CarrinhoNotifier(repository, userId);
});

/// Provider do notifier de pedidos
final pedidosProvider = StateNotifierProvider.family<PedidosNotifier, PedidosState, String>((ref, userId) {
  final repository = ref.watch(pedidosRepositoryProvider);
  return PedidosNotifier(repository, userId);
});

// ===== PROVIDERS DERIVADOS =====

/// Provider do usuário logado (derivado)
final usuarioLogadoProvider = Provider<Usuario?>((ref) {
  return ref.watch(userProvider).usuario;
});

/// Provider do status de login (derivado)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoggedIn;
});

/// Provider do status de carregamento do usuário (derivado)
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

/// Provider dos itens do carrinho (derivado)
final carrinhoItensProvider = Provider.family<List<CarrinhoItem>, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).itens;
});

/// Provider do total do carrinho (derivado)
final carrinhoTotalProvider = Provider.family<double, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).total;
});

/// Provider da quantidade total do carrinho (derivado)
final carrinhoQuantidadeTotalProvider = Provider.family<int, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).quantidadeTotal;
});

/// Provider do status de carregamento do carrinho (derivado)
final carrinhoCarregadoProvider = Provider.family<bool, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).carregado;
});

/// Provider dos pedidos (derivado)
final pedidosListProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidos;
});

/// Provider do pedido atual (derivado)
final pedidoAtualProvider = Provider.family<Pedido?, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidoAtual;
});

/// Provider do status de carregamento dos pedidos (derivado)
final pedidosCarregandoProvider = Provider.family<bool, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).carregando;
});

/// Provider dos pedidos pendentes (derivado)
final pedidosPendentesProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosPendentes;
});

/// Provider dos pedidos em andamento (derivado)
final pedidosEmAndamentoProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosEmAndamento;
});

/// Provider dos pedidos entregues (derivado)
final pedidosEntreguesProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosEntregues;
});

/// Provider dos pedidos cancelados (derivado)
final pedidosCanceladosProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosCancelados;
});

// ===== PROVIDERS COMPOSTOS =====

/// Provider que combina usuário logado e carrinho
final userCarrinhoProvider = Provider.family<({Usuario? user, List<CarrinhoItem> itens, double total}), String>((ref, userId) {
  final user = ref.watch(usuarioLogadoProvider);
  final itens = ref.watch(carrinhoItensProvider(userId));
  final total = ref.watch(carrinhoTotalProvider(userId));
  
  return (user: user, itens: itens, total: total);
});

/// Provider que combina usuário logado e pedidos
final userPedidosProvider = Provider.family<({Usuario? user, List<Pedido> pedidos, bool carregando}), String>((ref, userId) {
  final user = ref.watch(usuarioLogadoProvider);
  final pedidos = ref.watch(pedidosListProvider(userId));
  final carregando = ref.watch(pedidosCarregandoProvider(userId));
  
  return (user: user, pedidos: pedidos, carregando: carregando);
});