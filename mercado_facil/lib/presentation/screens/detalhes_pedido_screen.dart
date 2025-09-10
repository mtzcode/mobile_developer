import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/pedidos_provider.dart';
import '../../data/models/pedido.dart';
import '../widgets/pedido_status_widget.dart';

class DetalhesPedidoScreen extends StatefulWidget {
  final String pedidoId;

  const DetalhesPedidoScreen({
    super.key,
    required this.pedidoId,
  });

  @override
  State<DetalhesPedidoScreen> createState() => _DetalhesPedidoScreenState();
}

class _DetalhesPedidoScreenState extends State<DetalhesPedidoScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar detalhes do pedido quando a tela for inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pedidosProvider = Provider.of<PedidosProvider>(context, listen: false);
      pedidosProvider.carregarPedido(widget.pedidoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PedidosProvider>(
        builder: (context, pedidosProvider, child) {
          if (pedidosProvider.carregando) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (pedidosProvider.erro != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar pedido',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pedidosProvider.erro!,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => pedidosProvider.carregarPedido(widget.pedidoId),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final pedido = pedidosProvider.pedidoAtual;
          if (pedido == null) {
            return const Center(
              child: Text('Pedido não encontrado'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com status
                _buildStatusHeader(pedido),
                
                const SizedBox(height: 24),
                
                // Timeline do pedido
                _buildTimeline(pedido),
                
                const SizedBox(height: 24),
                
                // Informações do pedido
                _buildPedidoInfo(pedido),
                
                const SizedBox(height: 24),
                
                // Endereço de entrega
                if (pedido.enderecoEntrega != null)
                  _buildEnderecoEntrega(pedido),
                
                const SizedBox(height: 24),
                
                // Lista de itens
                _buildItensList(pedido),
                
                const SizedBox(height: 24),
                
                // Resumo financeiro
                _buildResumoFinanceiro(pedido),
                
                const SizedBox(height: 24),
                
                // Observações
                if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty)
                  _buildObservacoes(pedido),
                
                const SizedBox(height: 24),
                
                // Código de rastreamento
                if (pedido.codigoRastreamento != null)
                  _buildCodigoRastreamento(pedido),
                
                const SizedBox(height: 24),
                
                // Botões de ação
                _buildActionButtons(pedido, pedidosProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(Pedido pedido) {
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: pedido.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pedido.statusIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pedido.statusText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: pedido.statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pedido #${pedido.id.substring(0, 8)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Realizado em ${_formatDate(pedido.dataCriacao)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (pedido.dataConfirmacao != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Confirmado em ${_formatDate(pedido.dataConfirmacao!)}',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            if (pedido.dataEntrega != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Entregue em ${_formatDate(pedido.dataEntrega!)}',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(Pedido pedido) {
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                const Text(
                  'Progresso do Pedido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PedidoStatusWidget(
              pedido: pedido,
              showTimeline: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoInfo(Pedido pedido) {
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Método de Pagamento', pedido.metodoPagamento ?? 'Não informado'),
            const SizedBox(height: 8),
            _buildInfoRow('Total de Produtos', '${pedido.itens.fold(0, (soma, item) => soma + item.quantidade)} produtos'),
            const SizedBox(height: 8),
            _buildInfoRow('Subtotal', 'R\$ ${pedido.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildInfoRow('Taxa de Entrega', 'R\$ ${pedido.taxaEntrega.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildInfoRow('Total', 'R\$ ${pedido.total.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildEnderecoEntrega(Pedido pedido) {
    final endereco = pedido.enderecoEntrega!;
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Endereço de Entrega',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${endereco['logradouro'] ?? ''}, ${endereco['numero'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            if (endereco['complemento'] != null && endereco['complemento'].isNotEmpty)
              Text(
                endereco['complemento'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            Text(
              '${endereco['bairro'] ?? ''} - ${endereco['cidade'] ?? ''}, ${endereco['estado'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'CEP: ${endereco['cep'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItensList(Pedido pedido) {
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itens do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...pedido.itens.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Imagem do produto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.produto.imagemUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Informações do produto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.produto.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantidade: ${item.quantidade}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoFinanceiro(Pedido pedido) {
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Financeiro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildResumoRow('Subtotal', 'R\$ ${pedido.subtotal.toStringAsFixed(2)}'),
            _buildResumoRow('Taxa de Entrega', 'R\$ ${pedido.taxaEntrega.toStringAsFixed(2)}'),
            const Divider(),
            _buildResumoRow('Total', 'R\$ ${pedido.total.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildObservacoes(Pedido pedido) {
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Observações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pedido.observacoes!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodigoRastreamento(Pedido pedido) {
    return Card(
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Código de Rastreamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    pedido.codigoRastreamento!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Pedido pedido, PedidosProvider pedidosProvider) {
    return Column(
      children: [
        if (pedido.podeCancelar)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _confirmarCancelamento(pedido, pedidosProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancelar Pedido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Voltar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.green : Colors.black,
          ),
        ),
      ],
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
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmarCancelamento(Pedido pedido, PedidosProvider pedidosProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Cancelar Pedido'),
          content: Text(
            'Tem certeza que deseja cancelar o pedido #${pedido.id.substring(0, 8)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                navigator.pop();
                final sucesso = await pedidosProvider.cancelarPedido(pedido.id);
                
                if (sucesso) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Pedido cancelado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    navigator.pop(); // Voltar para a lista
                  }
                } else {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Erro ao cancelar pedido: ${pedidosProvider.erro}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }
}