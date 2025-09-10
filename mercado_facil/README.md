# 🛒 Mercado Fácil

[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.3.0-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-10.7.0-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Aplicativo de supermercado completo com autenticação, produtos, carrinho, pedidos e rastreamento**

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Tecnologias](#-tecnologias)
- [Arquitetura](#-arquitetura)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Uso](#-uso)
- [Testes](#-testes)
- [Deploy](#-deploy)
- [Contribuição](#-contribuição)
- [Licença](#-licença)

## 🎯 Sobre o Projeto

O **Mercado Fácil** é um aplicativo de supermercado desenvolvido em Flutter que oferece uma experiência completa de compras online. O projeto implementa uma arquitetura limpa com gerenciamento de estado robusto, cache inteligente, testes automatizados e interface responsiva.

### 🎨 Características Principais

- **Interface Moderna**: Design responsivo e acessível
- **Performance Otimizada**: Cache inteligente e paginação
- **Testes Automatizados**: Cobertura de 90%+ do código
- **Arquitetura Limpa**: Separação clara de responsabilidades
- **Firebase Integration**: Autenticação e banco de dados em tempo real

## ✨ Funcionalidades

### 🔐 Autenticação e Usuário

- [x] Cadastro e login de usuários
- [x] Recuperação de senha
- [x] Perfil de usuário com foto
- [x] Gerenciamento de endereços

### 🛍️ Produtos e Compras

- [x] Catálogo de produtos com imagens
- [x] Busca e filtros avançados
- [x] Sistema de favoritos
- [x] Carrinho de compras
- [x] Histórico de pedidos

### 📱 Interface e UX

- [x] Design responsivo (mobile, tablet, desktop)
- [x] Tema escuro/claro
- [x] Animações suaves
- [x] Loading states e skeleton screens
- [x] Feedback visual padronizado

### 🔧 Funcionalidades Técnicas

- [x] Cache inteligente com fallbacks
- [x] Paginação infinita
- [x] Tratamento de erros global
- [x] Logs estruturados
- [x] Testes automatizados

## 🛠️ Tecnologias

### Frontend

- **Flutter 3.19.0** - Framework UI
- **Dart 3.3.0** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Cached Network Image** - Cache de imagens

### Backend & Serviços

- **Firebase Authentication** - Autenticação
- **Cloud Firestore** - Banco de dados
- **Firebase Storage** - Armazenamento de imagens
- **Firebase Hosting** - Deploy web

### Testes & Qualidade

- **Flutter Test** - Framework de testes
- **Mockito** - Mocks para testes
- **Integration Test** - Testes de integração
- **Coverage** - Cobertura de código

### Ferramentas

- **VS Code** - IDE principal
- **Git** - Controle de versão
- **GitHub Actions** - CI/CD
- **Firebase CLI** - Deploy e configuração

## 🏗️ Arquitetura

```
lib/
├── core/                    # Camada de infraestrutura
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

### Padrões Arquiteturais

- **Clean Architecture** - Separação de responsabilidades
- **Provider Pattern** - Gerenciamento de estado
- **Repository Pattern** - Abstração de dados
- **Service Layer** - Lógica de negócio
- **Widget Composition** - Reutilização de componentes

## 🚀 Instalação

### Pré-requisitos

- Flutter 3.19.0 ou superior
- Dart 3.3.0 ou superior
- Android Studio / VS Code
- Conta Firebase

### Passos

1. **Clone o repositório**

   ```bash
   git clone https://github.com/seu-usuario/mercado_facil.git
   cd mercado_facil
   ```

2. **Instale as dependências**

   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**

   ```bash
   # Instale o Firebase CLI
   npm install -g firebase-tools

   # Faça login no Firebase
   firebase login

   # Configure o projeto
   firebase init
   ```

4. **Execute o projeto**
   ```bash
   flutter run
   ```

## ⚙️ Configuração

### Firebase Setup

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Ative Authentication, Firestore e Storage
3. Configure as regras de segurança
4. Adicione as configurações do projeto

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
FIREBASE_PROJECT_ID=seu-projeto-id
FIREBASE_API_KEY=sua-api-key
FIREBASE_AUTH_DOMAIN=seu-projeto.firebaseapp.com
FIREBASE_STORAGE_BUCKET=seu-projeto.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
```

### Configurações de Desenvolvimento

```yaml
# pubspec.yaml
environment:
  sdk: ">=3.3.0 <4.0.0"
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  # ... outras dependências
```

## 📱 Uso

### Funcionalidades Principais

#### Autenticação

```dart
// Login de usuário
await AuthService.login(email, password);

// Cadastro
await AuthService.register(name, email, password);
```

#### Produtos

```dart
// Carregar produtos
final produtos = await ProdutosService.getProdutos();

// Buscar produtos
final resultados = await ProdutosService.buscarProdutos(query);
```

#### Carrinho

```dart
// Adicionar ao carrinho
await CarrinhoProvider.adicionarProduto(produto);

// Finalizar compra
await PedidosService.criarPedido(carrinho);
```

### Navegação

O app utiliza navegação baseada em rotas nomeadas:

```dart
// Navegar para tela de produtos
Navigator.pushNamed(context, '/produtos');

// Navegar com parâmetros
Navigator.pushNamed(context, '/produto-detalhes',
  arguments: {'produtoId': '123'});
```

## 🧪 Testes

### Executar Testes

```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/unit/validators_test.dart

# Com cobertura
flutter test --coverage

# Testes de integração
flutter test test/integration/
```

### Cobertura de Código

```bash
# Gerar relatório de cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Tipos de Teste

- **Unitários**: Models, Services, Utils
- **Widget**: Componentes de UI
- **Integração**: Fluxos completos do app

## 🚀 Deploy

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build iOS
flutter build ios --release
```

### Web

```bash
# Build Web
flutter build web --release

# Deploy Firebase Hosting
firebase deploy --only hosting
```

### Configurações de Deploy

```yaml
# firebase.json
{
  "hosting":
    {
      "public": "build/web",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    },
}
```

## 🤝 Contribuição

### Como Contribuir

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra** um Pull Request

### Padrões de Código

- Siga o [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use [Flutter Lints](https://dart.dev/go/flutter-lints)
- Mantenha cobertura de testes acima de 90%
- Documente funções públicas

### Estrutura de Commits

```
feat: adiciona funcionalidade de busca
fix: corrige bug no carrinho
docs: atualiza documentação
test: adiciona testes para validação
refactor: refatora serviço de produtos
```

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 📞 Suporte

- **Email**: suporte@mercadofacil.com
- **Issues**: [GitHub Issues](https://github.com/seu-usuario/mercado_facil/issues)
- **Documentação**: [Wiki do Projeto](https://github.com/seu-usuario/mercado_facil/wiki)

## 🙏 Agradecimentos

- [Flutter Team](https://flutter.dev/) pelo framework incrível
- [Firebase](https://firebase.google.com/) pelos serviços de backend
- Comunidade Flutter pela inspiração e suporte

---

**Desenvolvido com ❤️ pela equipe Mercado Fácil**
