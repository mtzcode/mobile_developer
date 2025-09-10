import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/user_provider.dart';
import '../../data/services/endereco_service.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_utils.dart';

class CadastroEnderecoScreen extends StatefulWidget {
  const CadastroEnderecoScreen({super.key});

  @override
  State<CadastroEnderecoScreen> createState() => _CadastroEnderecoScreenState();
}

class _CadastroEnderecoScreenState extends State<CadastroEnderecoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController ufController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  String lastCepSearched = '';
  final EnderecoService _enderecoService = EnderecoService();

  @override
  void initState() {
    super.initState();
    cepController.addListener(_onCepChanged);
  }

  void _onCepChanged() {
    final cep = cepController.text.replaceAll(RegExp(r'[^\d]'), '');
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
    cidadeController.dispose();
    ufController.dispose();
    super.dispose();
  }

  Future<void> buscarEndereco(String cep) async {
    setState(() { isLoading = true; });
    
    try {
      final endereco = await _enderecoService.buscarEnderecoPorCep(cep);
      if (!mounted) return;
      
      if (endereco != null) {
        setState(() {
          enderecoController.text = endereco.logradouro;
          bairroController.text = endereco.bairro;
          cidadeController.text = endereco.cidade;
          ufController.text = endereco.uf;
        });
        
        showAppSnackBar(
          context,
          'Endereço encontrado!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );
      } else {
        showAppSnackBar(
          context,
          'CEP não encontrado!',
          icon: Icons.warning,
          backgroundColor: Colors.orange.shade600,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Erro ao buscar CEP: $e',
        icon: Icons.error,
        backgroundColor: Colors.red.shade600,
      );
    } finally {
      if (mounted) {
        setState(() { isLoading = false; });
      }
    }
  }

  Future<void> _salvarEndereco() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isSaving = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final novoEndereco = {
        'cep': cepController.text.replaceAll(RegExp(r'[^\d]'), ''),
        'logradouro': enderecoController.text,
        'numero': numeroController.text,
        'bairro': bairroController.text,
        'complemento': complementoController.text,
        'cidade': cidadeController.text,
        'estado': ufController.text,
      };
      
      // Adicionar o novo endereço à lista de endereços do usuário
      await userProvider.adicionarEndereco(novoEndereco);
      
      if (mounted) {
        showAppSnackBar(
          context,
          'Endereço adicionado com sucesso!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );
        
        // Retornar true para indicar sucesso
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao adicionar endereço: $e',
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Novo Endereço',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
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
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add_location, color: Colors.blue[700], size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Informações do Endereço',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // CEP
                        TextFormField(
                          controller: cepController,
                          decoration: InputDecoration(
                            labelText: 'CEP',
                            hintText: '00000-000',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: Validators.cep,
                        ),
                        const SizedBox(height: 16),
                        
                        // Endereço
                        TextFormField(
                          controller: enderecoController,
                          decoration: const InputDecoration(
                            labelText: 'Endereço',
                            hintText: 'Rua, Avenida, etc.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Endereço é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Número
                        TextFormField(
                          controller: numeroController,
                          decoration: const InputDecoration(
                            labelText: 'Número',
                            hintText: '123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Número é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Complemento
                        TextFormField(
                          controller: complementoController,
                          decoration: const InputDecoration(
                            labelText: 'Complemento (opcional)',
                            hintText: 'Apartamento, bloco, etc.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Bairro
                        TextFormField(
                          controller: bairroController,
                          decoration: const InputDecoration(
                            labelText: 'Bairro',
                            hintText: 'Nome do bairro',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bairro é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Cidade
                        TextFormField(
                          controller: cidadeController,
                          decoration: const InputDecoration(
                            labelText: 'Cidade',
                            hintText: 'Nome da cidade',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Cidade é obrigatória';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Estado
                        TextFormField(
                          controller: ufController,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            hintText: 'UF',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Estado é obrigatório';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _salvarEndereco,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Salvar Endereço',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}