import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/user_provider.dart';
import '../../data/services/endereco_service.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_utils.dart';

class EnderecosScreen extends StatefulWidget {
  const EnderecosScreen({super.key});

  @override
  State<EnderecosScreen> createState() => _EnderecosScreenState();
}

class _EnderecosScreenState extends State<EnderecosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController ufController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  String lastCepSearched = '';
  final EnderecoService _enderecoService = EnderecoService();

  @override
  void initState() {
    super.initState();
    _carregarEnderecoUsuario();
    cepController.addListener(_onCepChanged);
  }

  Future<void> _carregarEnderecoUsuario() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.carregarUsuarioLogado();
    
    final usuario = userProvider.usuarioLogado;
    if (usuario != null && usuario.endereco != null) {
      final endereco = usuario.endereco!;
      setState(() {
        cepController.text = endereco['cep'] ?? '';
        enderecoController.text = endereco['logradouro'] ?? '';
        numeroController.text = endereco['numero'] ?? '';
        bairroController.text = endereco['bairro'] ?? '';
        complementoController.text = endereco['complemento'] ?? '';
        ufController.text = endereco['uf'] ?? '';
      });
    }
  }

  void _onCepChanged() {
    final cep = cepController.text;
    if (cep.length == 8 && cep != lastCepSearched) {
      lastCepSearched = cep;
      buscarEndereco(cep);
    }
  }

  @override
  void dispose() {
    cepController.removeListener(_onCepChanged);
    cepController.dispose();
    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    complementoController.dispose();
    ufController.dispose();
    super.dispose();
  }

  Future<void> buscarEndereco(String cep) async {
    setState(() { isLoading = true; });
    
    try {
      final endereco = await _enderecoService.buscarEnderecoPorCep(cep);
      
      if (endereco != null) {
        setState(() {
          enderecoController.text = endereco.logradouro;
          bairroController.text = endereco.bairro;
          ufController.text = endereco.uf;
        });
        
        if (mounted) {
          showAppSnackBar(
            context,
            'Endereço encontrado!',
            icon: Icons.check_circle,
            backgroundColor: Colors.green.shade600,
          );
        }
      } else {
        if (mounted) {
          showAppSnackBar(
            context,
            'CEP não encontrado!',
            icon: Icons.warning,
            backgroundColor: Colors.orange.shade600,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao buscar CEP: $e',
          icon: Icons.error,
        backgroundColor: Colors.red.shade600,
      );
      }
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _salvarEndereco() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isSaving = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final dadosEndereco = {
        'endereco': {
          'cep': cepController.text,
          'logradouro': enderecoController.text,
          'numero': numeroController.text,
          'bairro': bairroController.text,
          'complemento': complementoController.text,
          'uf': ufController.text,
        },
        'dataAtualizacao': DateTime.now().toIso8601String(),
      };
      
      await userProvider.atualizarDadosUsuario(dadosEndereco);
      
      if (mounted) {
        showAppSnackBar(
          context,
          'Endereço atualizado com sucesso!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao atualizar endereço: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Endereço'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Alteração de Endereço',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cepController,
                  decoration: InputDecoration(
                    labelText: 'CEP',
                    labelStyle: TextStyle(color: colorScheme.tertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.cep,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: enderecoController,
                        decoration: InputDecoration(
                          labelText: 'Endereço',
                          labelStyle: TextStyle(color: colorScheme.tertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o endereço';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: numeroController,
                        decoration: InputDecoration(
                          labelText: 'Número',
                          labelStyle: TextStyle(color: colorScheme.tertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o número';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: bairroController,
                        decoration: InputDecoration(
                          labelText: 'Bairro',
                          labelStyle: TextStyle(color: colorScheme.tertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o bairro';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: ufController,
                        decoration: InputDecoration(
                          labelText: 'UF',
                          labelStyle: TextStyle(color: colorScheme.tertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a UF';
                          }
                          if (value.length != 2) {
                            return 'UF deve ter 2 letras';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: complementoController,
                  decoration: InputDecoration(
                    labelText: 'Complemento',
                    labelStyle: TextStyle(color: colorScheme.tertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSaving ? null : _salvarEndereco,
                  child: isSaving 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Salvar endereço'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}