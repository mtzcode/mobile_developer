# 🤝 Guia de Contribuição - Mercado Fácil

Obrigado por considerar contribuir com o Mercado Fácil! Este documento fornece diretrizes e informações importantes para contribuidores.

## 📋 Índice

- [Como Contribuir](#como-contribuir)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Padrões de Código](#padrões-de-código)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Testes](#testes)
- [Commits e Pull Requests](#commits-e-pull-requests)
- [Reportando Bugs](#reportando-bugs)
- [Solicitando Features](#solicitando-features)
- [Código de Conduta](#código-de-conduta)

## 🚀 Como Contribuir

### Tipos de Contribuição

- 🐛 **Bug Fixes**: Correções de bugs e problemas
- ✨ **Features**: Novas funcionalidades
- 📚 **Documentação**: Melhorias na documentação
- 🧪 **Testes**: Adição ou melhoria de testes
- 🎨 **UI/UX**: Melhorias na interface
- ⚡ **Performance**: Otimizações de performance
- 🔧 **Refatoração**: Melhorias no código existente

### Processo de Contribuição

1. **Fork** o repositório
2. **Clone** seu fork localmente
3. **Crie** uma branch para sua feature
4. **Desenvolva** sua contribuição
5. **Teste** suas mudanças
6. **Commit** seguindo as convenções
7. **Push** para sua branch
8. **Abra** um Pull Request

## ⚙️ Configuração do Ambiente

### Pré-requisitos

- Flutter 3.19.0 ou superior
- Dart 3.3.0 ou superior
- Android Studio / VS Code
- Git
- Conta Firebase (para testes)

### Setup Inicial

```bash
# 1. Fork e clone
git clone https://github.com/seu-usuario/mercado_facil.git
cd mercado_facil

# 2. Adicionar upstream
git remote add upstream https://github.com/original/mercado_facil.git

# 3. Instalar dependências
flutter pub get

# 4. Configurar Firebase (opcional para desenvolvimento)
firebase init

# 5. Executar testes
flutter test
```

### Configuração do IDE

#### VS Code

Instale as extensões recomendadas:

```json
{
  "recommendations": [
    "Dart-Code.dart-code",
    "Dart-Code.flutter",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss"
  ]
}
```

#### Android Studio

1. Instale o plugin Flutter
2. Configure o Dart SDK
3. Configure o Flutter SDK

### Configuração de Linting

O projeto usa Flutter Lints. Certifique-se de que seu `analysis_options.yaml` está configurado:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    prefer_single_quotes: true
    always_declare_return_types: true
```

## 📝 Padrões de Código

### Convenções de Nomenclatura

#### Classes e Widgets
```dart
// ✅ Correto
class ProdutoCard extends StatelessWidget
class AuthService
class UserProvider extends ChangeNotifier

// ❌ Incorreto
class produtoCard extends StatelessWidget
class authService
class userProvider extends ChangeNotifier
```

#### Variáveis e Métodos
```dart
// ✅ Correto
String nomeUsuario;
int quantidadeProdutos;
Future<void> carregarProdutos();
bool isUsuarioLogado;

// ❌ Incorreto
String NomeUsuario;
int QuantidadeProdutos;
Future<void> CarregarProdutos();
bool IsUsuarioLogado;
```

#### Constantes
```dart
// ✅ Correto
static const String apiBaseUrl = 'https://api.example.com';
static const double defaultPadding = 16.0;

// ❌ Incorreto
static const String API_BASE_URL = 'https://api.example.com';
static const double DEFAULT_PADDING = 16.0;
```

### Estrutura de Arquivos

```
lib/
├── core/                    # Infraestrutura
│   ├── constants/          # Constantes globais
│   ├── theme/             # Temas e estilos
│   ├── utils/             # Utilitários
│   ├── responsive/        # Sistema responsivo
│   └── accessibility/     # Acessibilidade
├── data/                   # Camada de dados
│   ├── models/            # Modelos de dados
│   ├── services/          # Serviços e APIs
│   └── repositories/      # Repositórios
├── presentation/           # Camada de apresentação
│   ├── screens/           # Telas do app
│   ├── widgets/           # Widgets reutilizáveis
│   └── providers/         # Providers de estado
└── main.dart              # Ponto de entrada
```

### Documentação de Código

#### Documentação de Classes
```dart
/// Serviço responsável por gerenciar autenticação de usuários.
/// 
/// Este serviço fornece métodos para login, registro, logout e
/// gerenciamento do estado de autenticação do usuário.
class AuthService {
  // Implementação...
}
```

#### Documentação de Métodos
```dart
/// Realiza login do usuário com email e senha.
/// 
/// [email] - Email do usuário
/// [password] - Senha do usuário
/// 
/// Retorna [User] em caso de sucesso.
/// 
/// Lança [AuthException] se as credenciais forem inválidas
/// ou se houver erro de conexão.
Future<User> login(String email, String password) async {
  // Implementação...
}
```

#### Documentação de Parâmetros
```dart
/// Widget que exibe um card de produto.
/// 
/// [produto] - Produto a ser exibido
/// [onAdicionarAoCarrinho] - Callback chamado ao adicionar ao carrinho
/// [onToggleFavorito] - Callback chamado ao favoritar/desfavoritar
class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback? onAdicionarAoCarrinho;
  final VoidCallback? onToggleFavorito;
  
  // Implementação...
}
```

## 🏗️ Estrutura do Projeto

### Organização de Widgets

```dart
// ✅ Widget bem organizado
class ProdutoCard extends StatelessWidget {
  // 1. Constantes
  static const double _cardHeight = 280.0;
  static const double _imageHeight = 120.0;
  
  // 2. Propriedades
  final Produto produto;
  final VoidCallback? onAdicionarAoCarrinho;
  final VoidCallback? onToggleFavorito;
  
  // 3. Construtor
  const ProdutoCard({
    super.key,
    required this.produto,
    this.onAdicionarAoCarrinho,
    this.onToggleFavorito,
  });
  
  // 4. Métodos privados
  void _showProductModal(BuildContext context) {
    // Implementação...
  }
  
  // 5. Build method
  @override
  Widget build(BuildContext context) {
    // Implementação...
  }
}
```

### Gerenciamento de Estado

```dart
// ✅ Provider bem estruturado
class ProdutosProvider extends ChangeNotifier {
  // 1. Propriedades privadas
  List<Produto> _produtos = [];
  bool _isLoading = false;
  String? _error;
  
  // 2. Getters
  List<Produto> get produtos => _produtos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 3. Métodos públicos
  Future<void> carregarProdutos() async {
    _setLoading(true);
    try {
      _produtos = await _produtosService.getProdutos();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // 4. Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

## 🧪 Testes

### Padrões de Teste

#### Testes Unitários
```dart
// ✅ Teste bem estruturado
group('Produto', () {
  late Produto produto;
  
  setUp(() {
    produto = Produto(
      id: '1',
      nome: 'Banana',
      preco: 5.99,
      categoria: 'Frutas',
      imagemUrl: 'https://example.com/banana.jpg',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );
  });
  
  group('toMap', () {
    test('deve converter produto para Map', () {
      final map = produto.toMap();
      
      expect(map['id'], equals('1'));
      expect(map['nome'], equals('Banana'));
      expect(map['preco'], equals(5.99));
    });
  });
  
  group('fromMap', () {
    test('deve criar produto a partir de Map', () {
      final map = produto.toMap();
      final produtoFromMap = Produto.fromMap(map, '1');
      
      expect(produtoFromMap.id, equals(produto.id));
      expect(produtoFromMap.nome, equals(produto.nome));
    });
  });
});
```

#### Testes de Widget
```dart
// ✅ Teste de widget bem estruturado
group('ProdutoCard Widget Tests', () {
  late Produto produtoTeste;
  
  setUp(() {
    produtoTeste = Produto(
      id: '1',
      nome: 'Banana Prata',
      preco: 5.99,
      imagemUrl: 'https://via.placeholder.com/150',
      categoria: 'Frutas',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );
  });
  
  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ProdutoCard(
          produto: produtoTeste,
          onAdicionarAoCarrinho: () {},
          onToggleFavorito: () {},
        ),
      ),
    );
  }
  
  testWidgets('deve renderizar card de produto', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    
    expect(find.text('Banana Prata'), findsOneWidget);
  });
});
```

### Executando Testes

```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/unit/models/produto_test.dart

# Com cobertura
flutter test --coverage

# Testes de integração
flutter test test/integration/

# Testes com relatório detalhado
flutter test --reporter=expanded
```

### Cobertura de Código

Mantenha a cobertura de testes acima de 90%:

```bash
# Gerar relatório de cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📝 Commits e Pull Requests

### Convenções de Commit

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona funcionalidade de busca de produtos
fix: corrige bug no carrinho de compras
docs: atualiza documentação da API
test: adiciona testes para validação de email
refactor: refatora serviço de produtos
style: corrige formatação do código
perf: otimiza performance do carregamento de imagens
ci: atualiza configuração do GitHub Actions
```

### Estrutura de Pull Request

#### Título
```
feat: adiciona sistema de notificações push
```

#### Descrição
```markdown
## 📋 Descrição

Adiciona sistema de notificações push para informar usuários sobre:
- Status de pedidos
- Promoções especiais
- Produtos em estoque

## 🎯 Mudanças

- [x] Implementa serviço de notificações
- [x] Adiciona tela de configurações de notificação
- [x] Integra com Firebase Cloud Messaging
- [x] Adiciona testes unitários

## 🧪 Testes

- [x] Testes unitários para NotificationService
- [x] Testes de widget para NotificationSettingsScreen
- [x] Testes de integração para fluxo completo

## 📸 Screenshots

| Antes | Depois |
|-------|--------|
| ![Antes](link-antes.png) | ![Depois](link-depois.png) |

## ✅ Checklist

- [x] Código segue os padrões do projeto
- [x] Testes foram adicionados/atualizados
- [x] Documentação foi atualizada
- [x] Não há warnings de lint
- [x] Cobertura de testes mantida acima de 90%

## 🔗 Relacionado

Closes #123
```

### Review Process

1. **Auto-review**: Revise seu próprio código antes de submeter
2. **Testes**: Certifique-se de que todos os testes passam
3. **Linting**: Execute `flutter analyze` e corrija warnings
4. **Documentação**: Atualize documentação se necessário
5. **Screenshots**: Adicione screenshots para mudanças de UI

## 🐛 Reportando Bugs

### Template de Bug Report

```markdown
## 🐛 Descrição do Bug

Descrição clara e concisa do bug.

## 🔄 Passos para Reproduzir

1. Vá para '...'
2. Clique em '...'
3. Role até '...'
4. Veja o erro

## ✅ Comportamento Esperado

Descrição do que deveria acontecer.

## 📱 Informações do Sistema

- **Dispositivo**: iPhone 12 / Samsung Galaxy S21
- **Sistema Operacional**: iOS 15.0 / Android 12
- **Versão do App**: 1.2.3
- **Flutter**: 3.19.0

## 📸 Screenshots

Se aplicável, adicione screenshots para ajudar a explicar o problema.

## 📋 Logs

```
[ERROR] Exception: ...
```

## 🔗 Contexto Adicional

Qualquer outra informação sobre o problema.
```

## 💡 Solicitando Features

### Template de Feature Request

```markdown
## 💡 Descrição da Feature

Descrição clara e concisa da funcionalidade desejada.

## 🎯 Problema que Resolve

Explicação de qual problema esta feature resolveria.

## 💭 Solução Proposta

Descrição da solução proposta.

## 🔄 Alternativas Consideradas

Outras soluções que foram consideradas.

## 📱 Mockups/Screenshots

Se aplicável, adicione mockups ou screenshots.

## 📋 Critérios de Aceitação

- [ ] Critério 1
- [ ] Critério 2
- [ ] Critério 3
```

## 📜 Código de Conduta

### Nossos Padrões

- Seja respeitoso e inclusivo
- Use linguagem apropriada
- Aceite críticas construtivas
- Foque no que é melhor para a comunidade
- Demonstre empatia para com outros membros

### Nossas Responsabilidades

- Manter um ambiente acolhedor e seguro
- Resolver conflitos de forma justa
- Remover, editar ou rejeitar comentários, commits, código e outras contribuições que não estejam alinhadas com este Código de Conduta

### Aplicação

Instâncias de comportamento abusivo, de assédio ou inaceitável podem ser reportadas entrando em contato com a equipe do projeto.

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/seu-usuario/mercado_facil/issues)
- **Discussions**: [GitHub Discussions](https://github.com/seu-usuario/mercado_facil/discussions)
- **Email**: contribuicao@mercadofacil.com

## 🙏 Agradecimentos

Obrigado por contribuir com o Mercado Fácil! Sua contribuição ajuda a tornar o app melhor para todos os usuários.

---

**Juntos, construímos o melhor app de supermercado! 🛒✨** 