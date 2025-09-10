import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/user_provider.dart';
import '../../core/utils/snackbar_utils.dart';

class EnderecosScreen extends StatefulWidget {
  const EnderecosScreen({super.key});

  @override
  State<EnderecosScreen> createState() => _EnderecosScreenState();
}

class _EnderecosScreenState extends State<EnderecosScreen> {
  @override
  void initState() {
    super.initState();
    _carregarEnderecos();
  }

  Future<void> _carregarEnderecos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.carregarUsuarioLogado();
  }

  Future<void> _definirComoPrincipal(Map<String, dynamic> endereco) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      // Definir como endereço principal
      await userProvider.atualizarDadosUsuario({
        'endereco': endereco,
        'dataAtualizacao': DateTime.now().toIso8601String(),
      });
      
      // Remover da lista de endereços secundários
      await _removerEnderecoSecundario(endereco);
      
      if (mounted) {
        showAppSnackBar(
          context,
          'Endereço definido como principal!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );
        _carregarEnderecos();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao definir endereço como principal: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  Future<void> _removerEnderecoSecundario(Map<String, dynamic> endereco) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usuario = userProvider.usuarioLogado;
    
    if (usuario?.enderecos != null) {
      final enderecosAtualizados = usuario!.enderecos!
          .where((end) => !_enderecosIguais(end, endereco))
          .toList();
      
      await userProvider.atualizarDadosUsuario({
        'enderecos': enderecosAtualizados,
        'dataAtualizacao': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _excluirEndereco(Map<String, dynamic> endereco) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este endereço?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _removerEnderecoSecundario(endereco);
      if (mounted) {
        showAppSnackBar(
          context,
          'Endereço excluído com sucesso!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );
        _carregarEnderecos();
      }
    }
  }

  bool _enderecosIguais(Map<String, dynamic> a, Map<String, dynamic> b) {
    return a['cep'] == b['cep'] &&
           a['logradouro'] == b['logradouro'] &&
           a['numero'] == b['numero'] &&
           a['bairro'] == b['bairro'] &&
           (a['complemento'] ?? '') == (b['complemento'] ?? '') &&
           a['uf'] == b['uf'];
  }

  String _formatarEndereco(Map<String, dynamic> endereco) {
    final logradouro = endereco['logradouro'] ?? '';
    final numero = endereco['numero'] ?? '';
    final bairro = endereco['bairro'] ?? '';
    final cidade = endereco['cidade'] ?? '';
    final uf = endereco['uf'] ?? '';
    final complemento = endereco['complemento'] ?? '';
    
    String enderecoFormatado = '$logradouro, $numero';
    if (complemento.isNotEmpty) {
      enderecoFormatado += ' - $complemento';
    }
    enderecoFormatado += '\n$bairro';
    if (cidade.isNotEmpty) {
      enderecoFormatado += ', $cidade';
    }
    if (uf.isNotEmpty) {
      enderecoFormatado += ' - $uf';
    }
    
    return enderecoFormatado;
  }

  Widget _buildEnderecoCard({
    required Map<String, dynamic> endereco,
    required bool isPrincipal,
    VoidCallback? onDefinirPrincipal,
    VoidCallback? onExcluir,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPrincipal 
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPrincipal ? Icons.home : Icons.location_on,
                  color: isPrincipal ? colorScheme.primary : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPrincipal ? 'Endereço Principal' : 'Endereço Secundário',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPrincipal ? colorScheme.primary : Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isPrincipal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRINCIPAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatarEndereco(endereco),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            if (endereco['cep'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'CEP: ${endereco['cep']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (!isPrincipal) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDefinirPrincipal,
                      icon: const Icon(Icons.home, size: 16),
                      label: const Text('Definir como Principal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onExcluir,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Excluir endereço',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Endereços'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,

      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final usuario = userProvider.usuarioLogado;
          
          if (usuario == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final enderecoPrincipal = usuario.endereco;
          final enderecosSecundarios = usuario.enderecos ?? [];
          
          // Filtrar endereços secundários para não duplicar o principal
          final enderecosSecundariosUnicos = enderecosSecundarios
              .where((endereco) => 
                  enderecoPrincipal == null || 
                  !_enderecosIguais(endereco, enderecoPrincipal))
              .toList();
          
          if (enderecoPrincipal == null && enderecosSecundariosUnicos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum endereço cadastrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione um endereço para continuar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro-endereco').then((result) {
                        if (result == true) {
                          _carregarEnderecos();
                        }
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Endereço'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _carregarEnderecos,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Endereço Principal
                if (enderecoPrincipal != null) ...[
                  _buildEnderecoCard(
                    endereco: enderecoPrincipal,
                    isPrincipal: true,
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Endereços Secundários
                if (enderecosSecundariosUnicos.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Outros Endereços',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...enderecosSecundariosUnicos.map((endereco) => 
                    _buildEnderecoCard(
                      endereco: endereco,
                      isPrincipal: false,
                      onDefinirPrincipal: () => _definirComoPrincipal(endereco),
                      onExcluir: () => _excluirEndereco(endereco),
                    ),
                  ),
                ],
                
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cadastro-endereco').then((result) {
            if (result == true) {
              _carregarEnderecos();
            }
          });
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}