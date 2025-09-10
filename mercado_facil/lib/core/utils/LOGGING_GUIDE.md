# 📋 Guia de Uso do Sistema de Logging

## Visão Geral

O sistema de logging profissional do Mercado Fácil foi implementado usando o pacote `logger` e fornece diferentes níveis e categorias de log para facilitar o debugging e monitoramento da aplicação.

## Configuração

### 1. Importar o Logger

```dart
import 'package:mercado_facil/core/utils/logger.dart';
```

### 2. Configurar Modo de Produção

O logger é configurado automaticamente no `main.dart`, mas você pode alterar manualmente:

```dart
// Modo desenvolvimento (todos os logs)
AppLogger.setProductionMode(false);

// Modo produção (apenas logs importantes)
AppLogger.setProductionMode(true);
```

## Níveis de Log

### Debug

Para informações detalhadas de desenvolvimento (não aparece em produção):

```dart
AppLogger.debug('Mensagem de debug');
AppLogger.debug('Debug com dados', {'chave': 'valor'});
```

### Info

Para informações gerais do app:

```dart
AppLogger.info('Informação geral');
AppLogger.info('Info com detalhes', 'Detalhes adicionais');
```

### Warning

Para avisos que não quebram a funcionalidade:

```dart
AppLogger.warning('Aviso importante');
AppLogger.warning('Aviso com erro', 'Detalhes', error, stackTrace);
```

### Error

Para erros que afetam a funcionalidade:

```dart
AppLogger.error('Erro na operação');
AppLogger.error('Erro com detalhes', error, stackTrace);
```

### Fatal

Para erros críticos que podem quebrar o app:

```dart
AppLogger.fatal('Erro crítico');
AppLogger.fatal('Erro fatal com detalhes', error, stackTrace);
```

## Categorias Específicas

### API/Firestore

```dart
AppLogger.api('Chamada para API');
AppLogger.api('Resposta da API', 'Dados recebidos');
```

### Cache

```dart
AppLogger.cache('Carregando cache');
AppLogger.cache('Cache salvo', 'Quantidade de itens: 10');
```

### Autenticação

```dart
AppLogger.auth('Usuário fazendo login');
AppLogger.auth('Login bem-sucedido', 'ID: 123');
```

### Carrinho

```dart
AppLogger.cart('Produto adicionado ao carrinho');
AppLogger.cart('Carrinho atualizado', 'Total: R$ 50,00');
```

### Pedidos

```dart
AppLogger.order('Pedido criado');
AppLogger.order('Status atualizado', 'Novo status: Confirmado');
```

### Produtos

```dart
AppLogger.product('Produtos carregados');
AppLogger.product('Busca realizada', 'Resultados: 15 produtos');
```

### UI

```dart
AppLogger.ui('Widget construído');
AppLogger.ui('Navegação realizada', 'Tela: Produtos');
```

### Navegação

```dart
AppLogger.navigation('Navegando para tela');
AppLogger.navigation('Navegação concluída', 'Destino: Carrinho');
```

### Performance

```dart
AppLogger.performance('Operação lenta detectada');
AppLogger.performance('Tempo de carregamento', '2.5 segundos');
```

### Segurança

```dart
AppLogger.security('Tentativa de acesso não autorizado');
AppLogger.security('Validação de dados', 'Dados inválidos detectados');
```

## Operações Especiais

### Início e Fim de Operação

```dart
AppLogger.startOperation('Carregamento de produtos');
// ... código da operação ...
AppLogger.endOperation('Carregamento de produtos');
```

### Sucesso e Falha

```dart
// Sucesso
AppLogger.success('Login realizado');
AppLogger.success('Pedido criado', 'ID: 12345');

// Falha
AppLogger.failure('Falha no login', 'Credenciais inválidas', error, stackTrace);
AppLogger.failure('Erro ao criar pedido', 'Dados incompletos', error, stackTrace);
```

### Avisos

```dart
AppLogger.warning('Operação com aviso', 'Dados podem estar desatualizados', error, stackTrace);
```

## Exemplos Práticos

### Exemplo 1: Serviço de Produtos

```dart
class ProdutosService {
  Future<List<Produto>> carregarProdutos() async {
    AppLogger.product('Iniciando carregamento de produtos');

    try {
      final produtos = await _firestore.collection('produtos').get();
      AppLogger.product('Produtos carregados com sucesso', 'Quantidade: ${produtos.docs.length}');
      return produtos.docs.map((doc) => Produto.fromMap(doc.data())).toList();
    } catch (e, stackTrace) {
      AppLogger.failure('Carregamento de produtos', 'Erro ao carregar do Firestore', e, stackTrace);
      return [];
    }
  }
}
```

### Exemplo 2: Provider de Carrinho

```dart
class CarrinhoProvider extends ChangeNotifier {
  void adicionarProduto(Produto produto) {
    AppLogger.cart('Adicionando produto', 'Nome: ${produto.nome}');

    try {
      // Lógica de adição
      _itens.add(CarrinhoItem(produto: produto));
      notifyListeners();

      AppLogger.success('Produto adicionado', 'Nome: ${produto.nome}');
    } catch (e, stackTrace) {
      AppLogger.failure('Adição de produto', 'Erro ao adicionar ao carrinho', e, stackTrace);
    }
  }
}
```

### Exemplo 3: Tela de Login

```dart
class LoginScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    AppLogger.ui('Construindo tela de login');

    return Scaffold(
      // ... código da tela
    );
  }

  Future<void> _fazerLogin() async {
    AppLogger.auth('Tentativa de login', 'Email: $email');

    try {
      await authService.login(email, senha);
      AppLogger.success('Login realizado', 'Email: $email');
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e, stackTrace) {
      AppLogger.failure('Login', 'Credenciais inválidas', e, stackTrace);
      // Mostrar erro para o usuário
    }
  }
}
```

## Boas Práticas

### 1. Use Categorias Específicas

```dart
// ❌ Ruim
AppLogger.info('Erro no carrinho');

// ✅ Bom
AppLogger.cart('Erro ao adicionar produto');
```

### 2. Inclua Contexto Relevante

```dart
// ❌ Ruim
AppLogger.error('Erro');

// ✅ Bom
AppLogger.error('Erro ao carregar produtos', error, stackTrace);
```

### 3. Use Operações Especiais para Fluxos Complexos

```dart
AppLogger.startOperation('Criação de pedido');
// ... código complexo ...
AppLogger.endOperation('Criação de pedido');
```

### 4. Não Logge Informações Sensíveis

```dart
// ❌ Ruim
AppLogger.auth('Login', 'Senha: 123456');

// ✅ Bom
AppLogger.auth('Login', 'Email: usuario@email.com');
```

### 5. Use Debug Apenas para Desenvolvimento

```dart
// Só aparece em desenvolvimento
AppLogger.debug('Dados internos do objeto', objeto.toMap());
```

## Configuração de Produção

Em produção, o sistema automaticamente:

- Remove logs de debug
- Simplifica stack traces
- Remove emojis e cores
- Mantém apenas logs essenciais

## Monitoramento

Para monitoramento em produção, considere:

- Integrar com serviços como Firebase Crashlytics
- Enviar logs críticos para análise
- Configurar alertas para erros fatais

## Troubleshooting

### Logs não aparecem

1. Verifique se o modo de produção está correto
2. Confirme se a importação está correta
3. Verifique se não há erros de sintaxe

### Logs muito verbosos

1. Use categorias específicas
2. Configure o nível de log apropriado
3. Use `debug` apenas para desenvolvimento

### Performance

1. Evite logs em loops
2. Use `debug` para logs detalhados
3. Considere usar `performance` para operações lentas
