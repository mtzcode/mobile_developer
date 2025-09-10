/// Sistema de labels descritivos para leitores de tela
class ScreenReaderLabels {
  // Labels para navegação
  static const String menuButton = 'Abrir menu de navegação';
  static const String backButton = 'Voltar';
  static const String closeButton = 'Fechar';
  static const String cancelButton = 'Cancelar';
  static const String confirmButton = 'Confirmar';
  static const String saveButton = 'Salvar';
  static const String editButton = 'Editar';
  static const String deleteButton = 'Excluir';
  static const String addButton = 'Adicionar';
  static const String removeButton = 'Remover';
  static const String searchButton = 'Pesquisar';
  static const String filterButton = 'Filtrar';
  static const String sortButton = 'Ordenar';
  static const String refreshButton = 'Atualizar';
  static const String shareButton = 'Compartilhar';
  static const String helpButton = 'Ajuda';
  static const String settingsButton = 'Configurações';

  // Labels para produtos
  static String productCard(String productName, double price, {String? discount}) {
    final baseLabel = 'Produto: $productName. Preço: R\$${price.toStringAsFixed(2)}';
    if (discount != null) {
      return '$baseLabel. $discount';
    }
    return baseLabel;
  }

  static String productInOffer(String productName, double originalPrice, double offerPrice) {
    return 'Produto: $productName. Preço original: R\$${originalPrice.toStringAsFixed(2)}. '
           'Preço promocional: R\$${offerPrice.toStringAsFixed(2)}. Em oferta.';
  }

  static String productNew(String productName, double price) {
    return 'Produto: $productName. Preço: R\$${price.toStringAsFixed(2)}. Produto novo.';
  }

  static String productBestSeller(String productName, double price) {
    return 'Produto: $productName. Preço: R\$${price.toStringAsFixed(2)}. Mais vendido.';
  }

  static String addToCart(String productName) {
    return 'Adicionar $productName ao carrinho';
  }

  static String removeFromCart(String productName) {
    return 'Remover $productName do carrinho';
  }

  static String addToFavorites(String productName) {
    return 'Adicionar $productName aos favoritos';
  }

  static String removeFromFavorites(String productName) {
    return 'Remover $productName dos favoritos';
  }

  static String productQuantity(int quantity, String productName) {
    return '$quantity unidades de $productName';
  }

  // Labels para carrinho
  static String cartItem(String productName, int quantity, double price) {
    return '$quantity unidades de $productName por R\$${price.toStringAsFixed(2)}';
  }

  static String cartTotal(double total) {
    return 'Total do carrinho: R\$${total.toStringAsFixed(2)}';
  }

  static String cartEmpty = 'Carrinho vazio';
  static String cartItems(int itemCount) {
    return '$itemCount ${itemCount == 1 ? 'item' : 'itens'} no carrinho';
  }

  // Labels para pedidos
  static String orderStatus(String status) {
    return 'Status do pedido: $status';
  }

  static String orderNumber(String orderNumber) {
    return 'Pedido número: $orderNumber';
  }

  static String orderDate(DateTime date) {
    return 'Data do pedido: ${_formatDate(date)}';
  }

  static String orderTotal(double total) {
    return 'Total do pedido: R\$${total.toStringAsFixed(2)}';
  }

  // Labels para endereços
  static String addressCard(String street, String city, String state) {
    return 'Endereço: $street, $city, $state';
  }

  static String addAddress = 'Adicionar novo endereço';
  static String editAddress = 'Editar endereço';
  static String deleteAddress = 'Excluir endereço';
  static String selectAddress = 'Selecionar endereço';

  // Labels para formulários
  static const String emailField = 'Campo de e-mail';
  static const String passwordField = 'Campo de senha';
  static const String confirmPasswordField = 'Campo de confirmação de senha';
  static const String nameField = 'Campo de nome';
  static const String phoneField = 'Campo de telefone';
  static const String cpfField = 'Campo de CPF';
  static const String cepField = 'Campo de CEP';
  static const String streetField = 'Campo de rua';
  static const String numberField = 'Campo de número';
  static const String complementField = 'Campo de complemento';
  static const String neighborhoodField = 'Campo de bairro';
  static const String cityField = 'Campo de cidade';
  static const String stateField = 'Campo de estado';

  // Labels para validação
  static const String requiredField = 'Campo obrigatório';
  static const String invalidEmail = 'E-mail inválido';
  static const String invalidPassword = 'Senha inválida';
  static const String invalidCPF = 'CPF inválido';
  static const String invalidPhone = 'Telefone inválido';
  static const String invalidCEP = 'CEP inválido';
  static const String passwordsDoNotMatch = 'Senhas não coincidem';
  static const String weakPassword = 'Senha muito fraca';
  static const String strongPassword = 'Senha forte';

  // Labels para feedback
  static const String loading = 'Carregando';
  static const String saving = 'Salvando';
  static const String updating = 'Atualizando';
  static const String deleting = 'Excluindo';
  static const String searching = 'Pesquisando';
  static const String success = 'Sucesso';
  static const String error = 'Erro';
  static const String warning = 'Aviso';
  static const String info = 'Informação';

  // Labels para notificações
  static String notificationReceived(String title) {
    return 'Notificação recebida: $title';
  }

  static String notificationRead(String title) {
    return 'Notificação lida: $title';
  }

  static String notificationDeleted(String title) {
    return 'Notificação excluída: $title';
  }

  // Labels para categorias
  static String categorySelected(String category) {
    return 'Categoria selecionada: $category';
  }

  static String categoryFilter(String category) {
    return 'Filtrar por categoria: $category';
  }

  // Labels para preços
  static String priceRange(double min, double max) {
    return 'Faixa de preço: de R\$${min.toStringAsFixed(2)} a R\$${max.toStringAsFixed(2)}';
  }

  static String priceFilter(double price) {
    return 'Filtrar por preço máximo: R\$${price.toStringAsFixed(2)}';
  }

  // Labels para paginação
  static String pageInfo(int currentPage, int totalPages) {
    return 'Página $currentPage de $totalPages';
  }

  static String loadMoreItems = 'Carregar mais itens';
  static String noMoreItems = 'Não há mais itens para carregar';

  // Labels para busca
  static String searchResults(int resultCount) {
    return '$resultCount ${resultCount == 1 ? 'resultado' : 'resultados'} encontrados';
  }

  static String noSearchResults = 'Nenhum resultado encontrado';
  static String searchPlaceholder = 'Digite para pesquisar produtos';

  // Labels para filtros
  static String filterApplied(String filterName) {
    return 'Filtro aplicado: $filterName';
  }

  static String filterRemoved(String filterName) {
    return 'Filtro removido: $filterName';
  }

  static String clearAllFilters = 'Limpar todos os filtros';

  // Labels para ações de usuário
  static String userLoggedIn(String userName) {
    return 'Usuário logado: $userName';
  }

  static String userLoggedOut = 'Usuário desconectado';
  static String profileUpdated = 'Perfil atualizado';
  static String passwordChanged = 'Senha alterada';

  // Labels para acessibilidade
  static String accessibilityModeEnabled = 'Modo de acessibilidade ativado';
  static String accessibilityModeDisabled = 'Modo de acessibilidade desativado';
  static String highContrastEnabled = 'Alto contraste ativado';
  static String highContrastDisabled = 'Alto contraste desativado';
  static String largeTextEnabled = 'Texto grande ativado';
  static String largeTextDisabled = 'Texto grande desativado';

  // Labels para erros
  static String networkError = 'Erro de conexão. Verifique sua internet.';
  static String serverError = 'Erro do servidor. Tente novamente.';
  static String timeoutError = 'Tempo limite excedido. Tente novamente.';
  static String authenticationError = 'Erro de autenticação. Faça login novamente.';
  static String permissionError = 'Permissão negada.';
  static String notFoundError = 'Item não encontrado.';
  static String validationError = 'Dados inválidos. Verifique as informações.';

  // Labels para sucessos
  static String itemAdded = 'Item adicionado com sucesso';
  static String itemRemoved = 'Item removido com sucesso';
  static String itemUpdated = 'Item atualizado com sucesso';
  static String orderPlaced = 'Pedido realizado com sucesso';
  static String paymentSuccessful = 'Pagamento realizado com sucesso';
  static String profileSaved = 'Perfil salvo com sucesso';
  static String addressSaved = 'Endereço salvo com sucesso';

  // Labels para confirmações
  static String confirmDelete = 'Tem certeza que deseja excluir?';
  static String confirmLogout = 'Tem certeza que deseja sair?';
  static String confirmCancel = 'Tem certeza que deseja cancelar?';
  static String confirmRemove = 'Tem certeza que deseja remover?';

  // Labels para estados vazios
  static String noProducts = 'Nenhum produto encontrado';
  static String noOrders = 'Nenhum pedido encontrado';
  static String noAddresses = 'Nenhum endereço cadastrado';
  static String noFavorites = 'Nenhum favorito adicionado';
  static String noNotifications = 'Nenhuma notificação';

  // Labels para ações de swipe
  static String swipeToDelete = 'Deslize para excluir';
  static String swipeToEdit = 'Deslize para editar';
  static String swipeToFavorite = 'Deslize para favoritar';

  // Labels para gestos
  static String doubleTapToZoom = 'Toque duas vezes para ampliar';
  static String longPressForOptions = 'Toque longo para opções';
  static String pinchToZoom = 'Pinça para ampliar ou reduzir';

  // Labels para orientação
  static String portraitMode = 'Modo retrato';
  static String landscapeMode = 'Modo paisagem';

  // Labels para tamanhos de fonte
  static String smallText = 'Texto pequeno';
  static String normalText = 'Texto normal';
  static String largeText = 'Texto grande';
  static String extraLargeText = 'Texto extra grande';

  // Labels para cores
  static String primaryColor = 'Cor primária';
  static String secondaryColor = 'Cor secundária';
  static String accentColor = 'Cor de destaque';
  static String errorColor = 'Cor de erro';
  static String successColor = 'Cor de sucesso';
  static String warningColor = 'Cor de aviso';

  // Função auxiliar para formatação de data
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Obtém label baseado no tipo de ação
  static String getActionLabel(String action, {Map<String, String>? parameters}) {
    switch (action.toLowerCase()) {
      case 'add':
        return parameters?['item'] != null 
            ? addToCart(parameters!['item']!)
            : addButton;
      case 'remove':
        return parameters?['item'] != null 
            ? removeFromCart(parameters!['item']!)
            : removeButton;
      case 'edit':
        return parameters?['item'] != null 
            ? 'Editar ${parameters!['item']}'
            : editButton;
      case 'delete':
        return parameters?['item'] != null 
            ? 'Excluir ${parameters!['item']}'
            : deleteButton;
      case 'save':
        return parameters?['item'] != null 
            ? 'Salvar ${parameters!['item']}'
            : saveButton;
      case 'search':
        return parameters?['query'] != null 
            ? 'Pesquisar por ${parameters!['query']}'
            : searchButton;
      case 'filter':
        return parameters?['filter'] != null 
            ? filterApplied(parameters!['filter']!)
            : filterButton;
      default:
        return action;
    }
  }

  /// Obtém label para estado de carregamento
  static String getLoadingLabel(String context) {
    switch (context.toLowerCase()) {
      case 'products':
        return 'Carregando produtos';
      case 'orders':
        return 'Carregando pedidos';
      case 'profile':
        return 'Carregando perfil';
      case 'addresses':
        return 'Carregando endereços';
      case 'cart':
        return 'Carregando carrinho';
      case 'search':
        return 'Pesquisando';
      case 'payment':
        return 'Processando pagamento';
      default:
        return loading;
    }
  }

  /// Obtém label para estado de erro
  static String getErrorLabel(String context) {
    switch (context.toLowerCase()) {
      case 'network':
        return networkError;
      case 'server':
        return serverError;
      case 'timeout':
        return timeoutError;
      case 'auth':
        return authenticationError;
      case 'permission':
        return permissionError;
      case 'not_found':
        return notFoundError;
      case 'validation':
        return validationError;
      default:
        return error;
    }
  }
}