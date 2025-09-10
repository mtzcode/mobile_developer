# 🔄 Migração para Riverpod - Mercado Fácil

Este documento explica a migração do gerenciamento de estado de Provider para Riverpod, mantendo toda a funcionalidade existente mas com melhor performance e reatividade.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura Implementada](#arquitetura-implementada)
- [Providers Migrados](#providers-migrados)
- [Como Usar](#como-usar)
- [Diferenças do Provider](#diferenças-do-provider)
- [Migração Gradual](#migração-gradual)
- [Testes](#testes)

## 🎯 Visão Geral

### Por que Riverpod?

- **Type Safety**: Compile-time safety para providers
- **Performance**: Melhor performance e menos rebuilds
- **Testabilidade**: Mais fácil de testar e mock
- **Reatividade**: Sistema reativo mais robusto
- **Dependency Injection**: Injeção de dependências nativa

### Padrão Repository

- **Abstração**: Interfaces que definem contratos
- **Implementações**: Diferentes implementações (Firestore, Mock, etc.)
- **Testabilidade**: Fácil mock para testes
- **Manutenibilidade**: Código mais limpo e organizado

## 🏗️ Arquitetura Implementada

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  State Layer    │    │  Data Layer     │
│                 │    │                 │    │                 │
│ Widgets         │◄──►│ Riverpod        │◄──►│ Repository      │
│ Screens         │    │ Providers       │    │ Services        │
│                 │    │                 │    │ Models          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Camadas

1. **UI Layer**: Widgets e screens (não alterado)
2. **State Layer**: Providers Riverpod com StateNotifier
3. **Data Layer**: Repositories e Services

## 🔧 Providers Migrados

### 1. UserProvider → UserNotifier

**Antes (Provider)**:

```dart
class UserProvider extends ChangeNotifier {
  Usuario? _usuarioLogado;
  bool _isLoading = false;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get isLoading => _isLoading;

  Future<void> carregarUsuarioLogado() async {
    // Implementação...
    notifyListeners();
  }
}
```

**Depois (Riverpod)**:

```dart
class UserState {
  final Usuario? usuarioLogado;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const UserState({...});
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _userRepository;

  UserNotifier(this._userRepository) : super(const UserState());

  Future<void> carregarUsuarioLogado() async {
    // Implementação...
    state = state.copyWith(...);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});
```

### 2. CarrinhoProvider → CarrinhoNotifier

**Antes (Provider)**:

```dart
class CarrinhoProvider extends ChangeNotifier {
  List<CarrinhoItem> _itens = [];

  List<CarrinhoItem> get itens => List.unmodifiable(_itens);
  double get total => _itens.fold(0, (soma, item) => soma + item.subtotal);

  void adicionarProduto(Produto produto) {
    // Implementação...
    notifyListeners();
  }
}
```

**Depois (Riverpod)**:

```dart
class CarrinhoState {
  final List<CarrinhoItem> itens;
  final bool carregado;
  final String? error;

  double get total => itens.fold(0, (soma, item) => soma + item.subtotal);
  int get quantidadeTotal => itens.fold(0, (soma, item) => soma + item.quantidade);
}

class CarrinhoNotifier extends StateNotifier<CarrinhoState> {
  final CarrinhoRepository _carrinhoRepository;
  final String userId;

  CarrinhoNotifier(this._carrinhoRepository, this.userId) : super(const CarrinhoState());

  void adicionarProduto(Produto produto) {
    // Implementação...
    state = state.copyWith(itens: newItens);
  }
}

final carrinhoProvider = StateNotifierProvider.family<CarrinhoNotifier, CarrinhoState, String>((ref, userId) {
  final repository = ref.watch(carrinhoRepositoryProvider);
  return CarrinhoNotifier(repository, userId);
});
```

### 3. PedidosProvider → PedidosNotifier

**Antes (Provider)**:

```dart
class PedidosProvider extends ChangeNotifier {
  List<Pedido> _pedidos = [];
  Pedido? _pedidoAtual;
  bool _carregando = false;

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  Pedido? get pedidoAtual => _pedidoAtual;
  bool get carregando => _carregando;
}
```

**Depois (Riverpod)**:

```dart
class PedidosState {
  final List<Pedido> pedidos;
  final Pedido? pedidoAtual;
  final bool carregando;
  final String? error;

  List<Pedido> get pedidosPendentes => pedidos.where((p) => p.status == StatusPedido.pendente).toList();
  List<Pedido> get pedidosEmAndamento => pedidos.where((p) => p.estaEmAndamento).toList();
}

class PedidosNotifier extends StateNotifier<PedidosState> {
  final PedidosRepository _pedidosRepository;
  final String userId;

  PedidosNotifier(this._pedidosRepository, this.userId) : super(const PedidosState());
}

final pedidosProvider = StateNotifierProvider.family<PedidosNotifier, PedidosState, String>((ref, userId) {
  final repository = ref.watch(pedidosRepositoryProvider);
  return PedidosNotifier(repository, userId);
});
```

## 📱 Como Usar

### 1. Configurar ProviderScope

**main.dart**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Usar Providers em Widgets

**Antes (Provider)**:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.usuarioLogado;
        final isLoading = userProvider.isLoading;

        if (isLoading) {
          return CircularProgressIndicator();
        }

        return Text('Olá, ${user?.nome}');
      },
    );
  }
}
```

**Depois (Riverpod)**:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(usuarioLogadoProvider);
    final isLoading = ref.watch(isLoadingProvider);

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return Text('Olá, ${user?.nome}');
  }
}
```

### 3. Usar Providers com Parâmetros

**Carrinho com userId**:

```dart
class CarrinhoWidget extends ConsumerWidget {
  final String userId;

  const CarrinhoWidget({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itens = ref.watch(carrinhoItensProvider(userId));
    final total = ref.watch(carrinhoTotalProvider(userId));

    return Column(
      children: [
        Text('Itens: ${itens.length}'),
        Text('Total: R\$ ${total.toStringAsFixed(2)}'),
      ],
    );
  }
}
```

### 4. Chamar Métodos dos Notifiers

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Chamar método do notifier
        await ref.read(userProvider.notifier).carregarUsuarioLogado();
      },
      child: Text('Carregar Usuário'),
    );
  }
}
```

### 5. Usar Providers Derivados

```dart
class PedidosWidget extends ConsumerWidget {
  final String userId;

  const PedidosWidget({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidosPendentes = ref.watch(pedidosPendentesProvider(userId));
    final pedidosEntregues = ref.watch(pedidosEntreguesProvider(userId));
    final carregando = ref.watch(pedidosCarregandoProvider(userId));

    if (carregando) {
      return CircularProgressIndicator();
    }

    return Column(
      children: [
        Text('Pendentes: ${pedidosPendentes.length}'),
        Text('Entregues: ${pedidosEntregues.length}'),
      ],
    );
  }
}
```

## 🔄 Diferenças do Provider

### Vantagens do Riverpod

1. **Type Safety**:

   ```dart
   // Provider - sem type safety
   final user = context.read<UserProvider>();

   // Riverpod - com type safety
   final user = ref.read(userProvider);
   ```

2. **Performance**:

   ```dart
   // Provider - rebuilds desnecessários
   Consumer<UserProvider>(
     builder: (context, provider, child) {
       return Text(provider.usuarioLogado?.nome ?? '');
     },
   )

   // Riverpod - rebuilds otimizados
   Consumer(
     builder: (context, ref, child) {
       final nome = ref.watch(usuarioLogadoProvider)?.nome ?? '';
       return Text(nome);
     },
   )
   ```

3. **Dependency Injection**:

   ```dart
   // Provider - injeção manual
   ChangeNotifierProvider(
     create: (context) => UserProvider(FirestoreAuthService()),
     child: MyWidget(),
   )

   // Riverpod - injeção automática
   final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
     final repository = ref.watch(userRepositoryProvider);
     return UserNotifier(repository);
   });
   ```

4. **Providers Derivados**:

   ```dart
   // Riverpod - providers derivados
   final isLoggedInProvider = Provider<bool>((ref) {
     return ref.watch(userProvider).isLoggedIn;
   });

   final userCarrinhoProvider = Provider.family<({Usuario? user, List<CarrinhoItem> itens}), String>((ref, userId) {
     final user = ref.watch(usuarioLogadoProvider);
     final itens = ref.watch(carrinhoItensProvider(userId));
     return (user: user, itens: itens);
   });
   ```

## 🔄 Migração Gradual

### Estratégia de Migração

1. **Fase 1**: Criar repositórios e providers Riverpod
2. **Fase 2**: Migrar widgets gradualmente
3. **Fase 3**: Remover providers antigos
4. **Fase 4**: Otimizar e refatorar

### Coexistência Temporária

```dart
// Manter providers antigos durante migração
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    // ... outros providers antigos
  ],
  child: ProviderScope(
    child: MyApp(),
  ),
)
```

### Migração de Widgets

```dart
// Widget antigo
class OldWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Text(provider.usuarioLogado?.nome ?? '');
      },
    );
  }
}

// Widget novo
class NewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nome = ref.watch(usuarioLogadoProvider)?.nome ?? '';
    return Text(nome);
  }
}
```

## 🧪 Testes

### Testando Providers Riverpod

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('UserProvider Tests', () {
    testWidgets('should show user name when logged in', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(MockUserRepository()),
          ],
          child: MaterialApp(
            home: MyWidget(),
          ),
        ),
      );

      // Testes...
    });
  });
}
```

### Mock de Repositórios

```dart
class MockUserRepository implements UserRepository {
  Usuario? _mockUser;

  @override
  Future<Usuario?> getUsuarioLogado() async {
    return _mockUser;
  }

  void setMockUser(Usuario user) {
    _mockUser = user;
  }
}
```

### Testando Notifiers

```dart
test('should update state when loading user', () async {
  final container = ProviderContainer();
  final notifier = container.read(userProvider.notifier);

  expect(container.read(userProvider).isLoading, false);

  notifier.carregarUsuarioLogado();

  expect(container.read(userProvider).isLoading, true);

  await Future.delayed(Duration(milliseconds: 100));

  expect(container.read(userProvider).isLoading, false);
});
```

## 📚 Recursos Adicionais

### Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Executar testes
flutter test

# Analisar código
flutter analyze
```

### Documentação

- [Riverpod Documentation](https://riverpod.dev/)
- [StateNotifierProvider](https://riverpod.dev/docs/providers/state_notifier_provider)
- [Provider.family](https://riverpod.dev/docs/concepts/reading#family)
- [Testing with Riverpod](https://riverpod.dev/docs/cookbooks/testing)

---

## ✅ Checklist de Migração

- [x] Adicionar dependência `flutter_riverpod`
- [x] Criar interfaces de repositórios
- [x] Implementar repositórios
- [x] Migrar UserProvider para Riverpod
- [x] Migrar CarrinhoProvider para Riverpod
- [x] Migrar PedidosProvider para Riverpod
- [x] Configurar injeção de dependências
- [x] Criar documentação
- [ ] Migrar widgets gradualmente
- [ ] Remover providers antigos
- [ ] Otimizar performance

---

**Migração concluída! 🚀✨**
