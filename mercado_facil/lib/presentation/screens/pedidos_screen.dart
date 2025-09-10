import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/pedidos_provider.dart';
import '../../data/services/user_provider.dart';
import '../../data/models/pedido.dart';
import 'detalhes_pedido_screen.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // Tab changed - could add filtering logic here if needed
        });
      }
    });

    // Carregar pedidos quando a tela for inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.usuarioLogado != null) {
        final pedidosProvider = Provider.of<PedidosProvider>(context, listen: false);
        pedidosProvider.carregarPedidos();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final pedidosProvider = Provider.of<PedidosProvider>(context, listen: false);
              pedidosProvider.carregarPedidos();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Pendentes'),
                Tab(text: 'Em Andamento'),
                Tab(text: 'Entregues'),
                Tab(text: 'Cancelados'),
              ],
            ),
          ),
          
          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPedidosList(StatusPedido.pendente),
                _buildPedidosList(StatusPedido.confirmado),
                _buildPedidosList(StatusPedido.entregue),
                _buildPedidosList(StatusPedido.cancelado),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedidosList(StatusPedido status) {
    return Consumer<PedidosProvider>(
      builder: (context, pedidosProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        if (pedidosProvider.carregando) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
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
                  'Erro ao carregar pedidos',
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
                  onPressed: () => pedidosProvider.carregarPedidos(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        List<Pedido> pedidosFiltrados = [];
        switch (status) {
          case StatusPedido.pendente:
            pedidosFiltrados = pedidosProvider.pedidosPendentes;
            break;
          case StatusPedido.confirmado:
            pedidosFiltrados = pedidosProvider.pedidosEmAndamento;
            break;
          case StatusPedido.entregue:
            pedidosFiltrados = pedidosProvider.pedidosEntregues;
            break;
          case StatusPedido.cancelado:
            pedidosFiltrados = pedidosProvider.pedidosCancelados;
            break;
          default:
            pedidosFiltrados = pedidosProvider.pedidos;
        }

        if (pedidosFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum pedido encontrado',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Você ainda não tem pedidos neste status',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => pedidosProvider.carregarPedidos(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidosFiltrados.length,
            itemBuilder: (context, index) {
              final pedido = pedidosFiltrados[index];
              return _buildPedidoCard(pedido);
            },
          ),
        );
      },
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white, // Fundo branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesPedidoScreen(pedidoId: pedido.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pedido.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: pedido.statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pedido.statusIcon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pedido.statusText,
                          style: TextStyle(
                            color: pedido.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${pedido.id.substring(0, 8)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Data do pedido
              Text(
                'Pedido realizado em ${_formatDate(pedido.dataCriacao)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Itens do pedido
              Text(
                '${pedido.itens.fold(0, (soma, item) => soma + item.quantidade)} produtos',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Lista de produtos (máximo 3)
              ...pedido.itens.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '• ${item.produto.nome}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'x${item.quantidade}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),
              
              if (pedido.itens.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${pedido.itens.skip(3).fold(0, (soma, item) => soma + item.quantidade)} mais produtos',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Total do pedido
              Row(
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'R\$ ${pedido.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              // Botão de ação se aplicável
              if (pedido.podeCancelar)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _confirmarCancelamento(pedido),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar Pedido'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmarCancelamento(Pedido pedido) {
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
                final pedidosProvider = Provider.of<PedidosProvider>(context, listen: false);
                final sucesso = await pedidosProvider.cancelarPedido(pedido.id);
                
                if (mounted) {
                  if (sucesso) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Pedido cancelado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
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