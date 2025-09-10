# Guia de Tratamento de Erros - Mercado Fácil

## 📋 Visão Geral

Este guia explica como usar o sistema centralizado de tratamento de erros implementado no Mercado Fácil, que inclui:

- **AppException**: Classe centralizada para exceções da aplicação
- **ErrorHandler**: Handler global para tratamento de erros
- **ErrorDialog**: Widget para exibição de mensagens de erro
- **LoadingOverlay**: Widget para indicadores de carregamento
- **Retry Mechanism**: Sistema automático de retry para operações críticas

## 🏗️ Arquitetura

```
lib/core/
├── exceptions/
│   └── app_exception.dart          # Classe centralizada de exceções
├── error/
│   └── error_handler.dart          # Handler global de erros
└── utils/
    └── logger.dart                 # Sistema de logging

lib/presentation/widgets/
├── error_dialog.dart               # Widget de diálogo de erro
└── loading_overlay.dart            # Widget de loading overlay
```

## 🚀 Como Usar

### 1. Criando Exceções Personalizadas

```dart
// Erro de rede
throw AppException.networkError(
  message: 'Falha na conexão com o servidor',
  userMessage: 'Verifique sua conexão com a internet',
  originalError: e,
  stackTrace: stackTrace,
);

// Erro de validação
throw AppException.validationError(
  message: 'Dados inválidos',
  userMessage: 'Preencha todos os campos obrigatórios',
  fieldErrors: {'email': 'Email inválido', 'senha': 'Senha muito curta'},
);

// Erro de estoque insuficiente
throw AppException.insufficientStock(
  message: 'Produto sem estoque',
  userMessage: 'Quantidade solicitada não disponível',
  productName: 'Arroz Integral',
  availableQuantity: 5,
);
```

### 2. Tratando Erros com ErrorHandler

```dart
// Tratamento simples
try {
  await minhaOperacao();
} catch (e, stackTrace) {
  await ErrorHandler.handleError(
    e,
    stackTrace: stackTrace,
    context: 'Minha Operação',
    showToUser: true,
  );
}

// Tratamento com AppException específica
try {
  await minhaOperacao();
} catch (e, stackTrace) {
  if (e is AppException) {
    await ErrorHandler.handleException(
      e,
      context: 'Minha Operação',
      showToUser: true,
    );
  } else {
    await ErrorHandler.handleError(
      e,
      stackTrace: stackTrace,
      context: 'Minha Operação',
    );
  }
}
```

### 3. Usando Retry Mechanism

```dart
// Operação com retry automático
final resultado = await ErrorHandler.executeWithRetry(
  operation: () async {
    return await minhaOperacaoCritica();
  },
  operationName: 'Minha Operação Crítica',
  maxRetries: 3,
  delay: Duration(seconds: 2),
  showLoading: true,
);

// Operação com fallback
final resultado = await ErrorHandler.executeWithFallback(
  primaryOperation: () async {
    return await operacaoPrimaria();
  },
  fallbackOperation: () async {
    return await operacaoFallback();
  },
  operationName: 'Operação com Fallback',
);
```

### 4. Exibindo Diálogos de Erro

```dart
// Diálogo simples
await ErrorDialog.show(
  context,
  message: 'Erro ao carregar dados',
  title: 'Erro de Conexão',
  icon: Icons.wifi_off,
  color: Colors.orange,
);

// Diálogo a partir de AppException
await ErrorDialog.showFromException(
  context,
  minhaAppException,
  onRetry: () => tentarNovamente(),
  showRetryButton: true,
);

// Diálogo com retry
await ErrorDialog.show(
  context,
  message: 'Falha na conexão',
  title: 'Erro de Rede',
  onRetry: () => tentarNovamente(),
  showRetryButton: true,
);
```

### 5. Usando Loading Overlay

```dart
// Overlay simples
LoadingOverlay.show(
  context,
  message: 'Carregando dados...',
);

// Esconder overlay
LoadingOverlay.hide(context);

// Widget wrapper
LoadingWrapper(
  isLoading: _isLoading,
  loadingMessage: 'Processando...',
  child: MinhaTela(),
)
```

## 📝 Exemplos Práticos

### Exemplo 1: Serviço de Autenticação

```dart
class AuthService {
  Future<void> fazerLogin(String email, String senha) async {
    return ErrorHandler.executeWithRetry(
      operation: () async {
        // Validação
        if (email.isEmpty || senha.isEmpty) {
          throw AppException.validationError(
            message: 'Email e senha são obrigatórios',
            userMessage: 'Preencha todos os campos',
          );
        }

        if (!email.contains('@')) {
          throw AppException.validationError(
            message: 'Email inválido',
            userMessage: 'Digite um email válido',
            fieldErrors: {'email': 'Formato inválido'},
          );
        }

        // Tentativa de login
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: senha,
          );
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case 'user-not-found':
              throw AppException.authenticationError(
                message: 'Usuário não encontrado',
                userMessage: 'Email ou senha incorretos',
                originalError: e,
              );
            case 'wrong-password':
              throw AppException.authenticationError(
                message: 'Senha incorreta',
                userMessage: 'Email ou senha incorretos',
                originalError: e,
              );
            default:
              throw AppException.authenticationError(
                message: 'Erro de autenticação',
                userMessage: 'Erro ao fazer login. Tente novamente',
                originalError: e,
              );
          }
        }
      },
      operationName: 'Login do usuário',
      maxRetries: 2,
    );
  }
}
```

### Exemplo 2: Tela com Tratamento de Erros

```dart
class MinhaTela extends StatefulWidget {
  @override
  _MinhaTelaState createState() => _MinhaTelaState();
}

class _MinhaTelaState extends State<MinhaTela> {
  bool _isLoading = false;
  List<Produto> _produtos = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _isLoading = true);

    try {
      final produtos = await ErrorHandler.executeWithRetry(
        operation: () => ProdutosService().buscarProdutos(),
        operationName: 'Carregamento de produtos',
        maxRetries: 3,
        showLoading: false, // Controlamos manualmente
      );

      setState(() {
        _produtos = produtos;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() => _isLoading = false);

      await ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Carregamento de produtos',
        showToUser: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      isLoading: _isLoading,
      loadingMessage: 'Carregando produtos...',
      child: Scaffold(
        appBar: AppBar(title: Text('Produtos')),
        body: RefreshIndicator(
          onRefresh: _carregarProdutos,
          child: ListView.builder(
            itemCount: _produtos.length,
            itemBuilder: (context, index) {
              return ProdutoCard(produto: _produtos[index]);
            },
          ),
        ),
      ),
    );
  }
}
```

### Exemplo 3: Provider com Tratamento de Erros

```dart
class ProdutosProvider with ChangeNotifier {
  final ProdutosService _service = ProdutosService();
  List<Produto> _produtos = [];
  bool _isLoading = false;
  String? _error;

  List<Produto> get produtos => _produtos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> carregarProdutos() async {
    _setLoading(true);
    _clearError();

    try {
      final produtos = await ErrorHandler.executeWithRetry(
        operation: () => _service.buscarProdutos(),
        operationName: 'Carregamento de produtos',
        maxRetries: 3,
        showLoading: false,
      );

      _produtos = produtos;
      _setLoading(false);
    } catch (e, stackTrace) {
      _setLoading(false);

      // Log do erro
      await ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'ProdutosProvider.carregarProdutos',
        showToUser: false, // Não mostrar diálogo aqui
      );

      // Definir erro para exibição na UI
      if (e is AppException) {
        _setError(e.displayMessage);
      } else {
        _setError('Erro ao carregar produtos');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
```

## 🔧 Configuração

### 1. Configurar ErrorHandler no main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar ErrorHandler
  ErrorHandler.configure(
    showError: (message, {title, icon, color}) {
      // Implementar exibição de erro (ex: SnackBar, Dialog)
    },
    showLoading: (show) {
      // Implementar exibição de loading
    },
    navigate: (route, {arguments}) {
      // Implementar navegação
    },
  );

  runApp(MyApp());
}
```

### 2. Configurar em uma tela específica

```dart
class MinhaTela extends StatefulWidget {
  @override
  _MinhaTelaState createState() => _MinhaTelaState();
}

class _MinhaTelaState extends State<MinhaTela> {
  @override
  void initState() {
    super.initState();
    _configurarErrorHandler();
  }

  void _configurarErrorHandler() {
    ErrorHandler.configure(
      showError: (message, {title, icon, color}) {
        ErrorDialog.show(
          context,
          message: message,
          title: title,
          icon: icon,
          color: color,
        );
      },
      showLoading: (show) {
        if (show) {
          LoadingOverlay.show(context, message: 'Carregando...');
        } else {
          LoadingOverlay.hide(context);
        }
      },
      navigate: (route, {arguments}) {
        Navigator.of(context).pushNamed(route, arguments: arguments);
      },
    );
  }
}
```

## 📊 Tipos de Exceção Disponíveis

### Exceções de Rede

- `AppException.networkError()` - Erro de conexão
- `AppException.timeoutError()` - Timeout
- `AppException.connectionError()` - Erro de conexão

### Exceções de Autenticação

- `AppException.authenticationError()` - Erro de autenticação
- `AppException.authorizationError()` - Erro de autorização
- `AppException.sessionExpired()` - Sessão expirada

### Exceções de Dados

- `AppException.dataNotFound()` - Dados não encontrados
- `AppException.invalidData()` - Dados inválidos
- `AppException.validationError()` - Erro de validação

### Exceções do Firebase

- `AppException.firebaseError()` - Erro do Firebase
- `AppException.firestoreError()` - Erro do Firestore
- `AppException.storageError()` - Erro do Storage

### Exceções de Negócio

- `AppException.businessLogicError()` - Erro de lógica de negócio
- `AppException.insufficientStock()` - Estoque insuficiente
- `AppException.paymentError()` - Erro de pagamento

### Exceções Genéricas

- `AppException.unknownError()` - Erro desconhecido
- `AppException.serverError()` - Erro do servidor
- `AppException.clientError()` - Erro do cliente

## 🎯 Boas Práticas

### 1. Sempre Use AppException

```dart
// ❌ Ruim
throw Exception('Erro genérico');

// ✅ Bom
throw AppException.validationError(
  message: 'Dados inválidos',
  userMessage: 'Preencha todos os campos',
);
```

### 2. Forneça Mensagens para o Usuário

```dart
// ❌ Ruim
throw AppException.networkError(
  message: 'Connection timeout',
);

// ✅ Bom
throw AppException.networkError(
  message: 'Connection timeout',
  userMessage: 'Verifique sua conexão e tente novamente',
);
```

### 3. Use Retry para Operações Críticas

```dart
// ✅ Bom
final resultado = await ErrorHandler.executeWithRetry(
  operation: () => operacaoCritica(),
  operationName: 'Operação Crítica',
  maxRetries: 3,
);
```

### 4. Log Erros Apropriadamente

```dart
// ✅ Bom
await ErrorHandler.handleError(
  e,
  stackTrace: stackTrace,
  context: 'Contexto da operação',
  logError: true,
  showToUser: true,
);
```

### 5. Trate Erros Específicos

```dart
// ✅ Bom
try {
  await operacao();
} on AppException catch (e) {
  if (e.isAuthError) {
    // Redirecionar para login
    Navigator.pushNamed(context, '/login');
  } else if (e.isNetworkError) {
    // Mostrar mensagem de rede
    _mostrarErroRede();
  } else {
    // Tratamento genérico
    await ErrorHandler.handleException(e);
  }
}
```

## 🐛 Debugging

### 1. Verificar Logs

```dart
// Os logs são automaticamente gerados pelo ErrorHandler
// Verifique o console para detalhes dos erros
```

### 2. Testar Diferentes Cenários

```dart
// Teste sem internet
// Teste com dados inválidos
// Teste com timeout
// Teste com erros do Firebase
```

### 3. Verificar Configuração

```dart
// Certifique-se de que ErrorHandler está configurado
// Verifique se os callbacks estão funcionando
```

## 📚 Recursos Adicionais

- [Documentação do Logger](LOGGING_GUIDE.md)
- [Exemplos de Uso](../examples/error_handling_examples.dart)
- [Testes](../tests/error_handling_test.dart)

---

**Nota**: Este sistema de tratamento de erros foi projetado para ser robusto, escalável e fácil de usar. Sempre teste diferentes cenários de erro para garantir que sua aplicação responda adequadamente.
