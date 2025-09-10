import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/pedidos_provider.dart';
import '../../data/services/carrinho_provider.dart';
import '../../data/services/user_provider.dart';

import '../../core/utils/snackbar_utils.dart';

class ConfirmacaoPedidoScreen extends StatefulWidget {
  const ConfirmacaoPedidoScreen({super.key});

  @override
  State<ConfirmacaoPedidoScreen> createState() => _ConfirmacaoPedidoScreenState();
}

class _ConfirmacaoPedidoScreenState extends State<ConfirmacaoPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();
  String _metodoPagamento = 'Dinheiro';
  Map<String, dynamic>? _enderecoSelecionado;
  bool _aceiteTermos = false;

  final List<String> _metodosPagamento = [
    'Dinheiro',
    'Cartão de Crédito',
    'Cartão de Débito',
    'PIX',
  ];

  @override
  void initState() {
    super.initState();
    // Carregar endereço padrão do usuário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.usuarioLogado?.endereco != null) {
        setState(() {
          _enderecoSelecionado = userProvider.usuarioLogado!.endereco;
        });
      }
    });
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fundo suave e elegante
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<CarrinhoProvider, UserProvider>(
        builder: (context, carrinhoProvider, userProvider, child) {
          if (!carrinhoProvider.carregado) {
            return Container(
              color: Colors.grey[50],
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            );
          }

          if (carrinhoProvider.itens.isEmpty) {
            return Container(
              color: Colors.grey[50],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Carrinho vazio',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione produtos ao carrinho para fazer um pedido',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            color: Colors.grey[50],
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo do pedido
                    _buildResumoPedido(carrinhoProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Endereço de entrega
                    _buildEnderecoEntrega(userProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Método de pagamento
                    _buildMetodoPagamento(),
                    
                    const SizedBox(height: 24),
                    
                    // Observações
                    _buildObservacoes(),
                    
                    const SizedBox(height: 24),
                    
                    // Termos e condições
                    _buildTermosCondicoes(),
                    
                    const SizedBox(height: 32),
                    
                    // Botão de finalizar pedido
                    _buildBotaoFinalizar(carrinhoProvider, userProvider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumoPedido(CarrinhoProvider carrinhoProvider) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.shopping_cart, color: Colors.green[700], size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Resumo do Pedido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Lista compacta de itens (apenas texto)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: carrinhoProvider.itens.length,
                  itemBuilder: (context, index) {
                    final item = carrinhoProvider.itens[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${item.quantidade}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.produto.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'R\$ ${item.produto.preco.toStringAsFixed(2)} cada',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'R\$ ${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Mostrar total de produtos se houver muitos
              if (carrinhoProvider.quantidadeTotal > 10) ...[
                const Divider(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${carrinhoProvider.quantidadeTotal} produtos no total',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Divider(height: 32),
              
              // Resumo financeiro
              _buildResumoRow('Subtotal', 'R\$ ${carrinhoProvider.total.toStringAsFixed(2)}'),
              _buildResumoRow('Taxa de Entrega', 'R\$ 5.00'),
              const Divider(height: 24),
              _buildResumoRow('Total', 'R\$ ${(carrinhoProvider.total + 5.0).toStringAsFixed(2)}', isTotal: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnderecoEntrega(UserProvider userProvider) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7F7F7), // Cinza quase branco para leve destaque
              Color(0xFFF7F7F7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Endereço de Entrega',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              if (_enderecoSelecionado != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 0,
                    color: Color(0xFFF7F7F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_enderecoSelecionado!['logradouro'] ?? ''}, ${_enderecoSelecionado!['numero'] ?? ''}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          if (_enderecoSelecionado!['complemento'] != null && _enderecoSelecionado!['complemento'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _enderecoSelecionado!['complemento'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${_enderecoSelecionado!['bairro'] ?? ''} - ${_enderecoSelecionado!['cidade'] ?? ''}, ${_enderecoSelecionado!['estado'] ?? ''}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'CEP: ${_enderecoSelecionado!['cep'] ?? ''}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _mostrarDialogEnderecos(),
                        icon: const Icon(Icons.edit_location, size: 18),
                        label: const Text('Alterar Endereço'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          side: BorderSide(color: Colors.blue[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _adicionarNovoEndereco(),
                        icon: const Icon(Icons.add_location, size: 18),
                        label: const Text('Novo Endereço'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[700],
                          side: BorderSide(color: Colors.green[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nenhum endereço cadastrado',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _adicionarNovoEndereco(),
                        icon: const Icon(Icons.add_location, size: 18),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        label: const Text('Cadastrar Endereço'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetodoPagamento() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.payment, color: Colors.orange[700], size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Método de Pagamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: _metodosPagamento.map((metodo) => ListTile(
                    leading: Icon(
                      _metodoPagamento == metodo ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _metodoPagamento == metodo ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      metodo,
                      style: const TextStyle(fontSize: 16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      setState(() {
                        _metodoPagamento = metodo;
                      });
                    },
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObservacoes() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.note, color: Colors.purple[700], size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Observações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _observacoesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Adicione observações sobre o pedido (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermosCondicoes() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.security, color: Colors.red[700], size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Termos e Condições',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: CheckboxListTile(
                  title: const Text(
                    'Li e aceito os termos e condições',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  value: _aceiteTermos,
                  onChanged: (value) {
                    setState(() {
                      _aceiteTermos = value!;
                    });
                  },
                  activeColor: Colors.green,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoFinalizar(CarrinhoProvider carrinhoProvider, UserProvider userProvider) {
    return Consumer<PedidosProvider>(
      builder: (context, pedidosProvider, child) {
        return Column(
          children: [
            if (pedidosProvider.erro != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  pedidosProvider.erro!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _podeFinalizar() && !pedidosProvider.carregando
                    ? () => _finalizarPedido(carrinhoProvider, userProvider, pedidosProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: pedidosProvider.carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Finalizar Pedido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResumoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  bool _podeFinalizar() {
    return _enderecoSelecionado != null && _aceiteTermos;
  }

  Future<void> _finalizarPedido(
    CarrinhoProvider carrinhoProvider,
    UserProvider userProvider,
    PedidosProvider pedidosProvider,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final pedidoId = await pedidosProvider.criarPedido(
      itens: carrinhoProvider.itens,
      enderecoEntrega: _enderecoSelecionado!,
      metodoPagamento: _metodoPagamento,
      observacoes: _observacoesController.text.trim().isEmpty
          ? null
          : _observacoesController.text.trim(),
    );

    if (pedidoId != null) {
      // Limpar carrinho após sucesso
      carrinhoProvider.limparCarrinho();
      
      if (mounted) {
        // Mostrar sucesso
        showAppSnackBar(
          context,
          'Pedido realizado com sucesso! Acesse "Meus Pedidos" no menu para acompanhar.',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Ver Pedidos',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/pedidos', (route) => false);
            },
          ),
        );

        // Navegar de volta à tela principal
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao finalizar pedido: ${pedidosProvider.erro}',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  void _mostrarDialogEnderecos() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usuario = userProvider.usuarioLogado;

    // Sempre inclui o endereço principal na lista, sem duplicar
    List<Map<String, dynamic>> enderecosParaMostrar = [];
    if (usuario?.endereco != null) {
      enderecosParaMostrar.add(usuario!.endereco!);
    }
    if (usuario?.enderecos != null && usuario!.enderecos!.isNotEmpty) {
      for (var end in usuario.enderecos!) {
        if (usuario.endereco == null || !_enderecosIguais(usuario.endereco!, end)) {
          enderecosParaMostrar.add(end);
        }
      }
    }

    if (enderecosParaMostrar.isEmpty) {
      _adicionarNovoEndereco();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Selecionar Endereço'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...enderecosParaMostrar.map((endereco) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Color(0xFFF7F7F7), // Fundo claro para melhor legibilidade
                child: ListTile(
                  leading: Icon(
                    _enderecoSelecionado == endereco ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: _enderecoSelecionado == endereco ? Colors.green : Colors.grey,
                  ),
                  onTap: () {
                    setState(() {
                      _enderecoSelecionado = endereco;
                    });
                    Navigator.of(context).pop();
                  },
                  title: Text(
                    '${endereco['logradouro'] ?? ''}, ${endereco['numero'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (endereco['complemento'] != null && endereco['complemento'].isNotEmpty)
                        Text(endereco['complemento']),
                      Text(
                        '${endereco['bairro'] ?? ''} - ${endereco['cidade'] ?? ''}, ${endereco['estado'] ?? ''}',
                      ),
                      Text('CEP: ${endereco['cep'] ?? ''}'),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _adicionarNovoEndereco();
                  },
                  icon: const Icon(Icons.add_location, size: 18),
                  label: const Text('Adicionar Novo Endereço'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[300]!),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // Função para comparar endereços (evita duplicidade)
  bool _enderecosIguais(Map<String, dynamic> a, Map<String, dynamic> b) {
    return a['cep'] == b['cep'] &&
           a['logradouro'] == b['logradouro'] &&
           a['numero'] == b['numero'] &&
           a['bairro'] == b['bairro'] &&
           (a['complemento'] ?? '') == (b['complemento'] ?? '') &&
           a['uf'] == b['uf'];
  }

  void _adicionarNovoEndereco() {
    // Navegar para tela de cadastro de endereço
    Navigator.pushNamed(context, '/cadastro-endereco').then((result) {
      if (result == true && mounted) {
        // Recarregar endereços do usuário
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.carregarUsuario();
        
        // Atualizar endereço selecionado se necessário
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (userProvider.usuarioLogado?.endereco != null) {
            setState(() {
              _enderecoSelecionado = userProvider.usuarioLogado!.endereco;
            });
          }
        });
      }
    });
  }
}