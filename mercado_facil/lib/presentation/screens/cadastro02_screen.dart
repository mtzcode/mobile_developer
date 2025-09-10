import 'package:flutter/material.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/endereco_service.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_utils.dart';

class Cadastro02Screen extends StatefulWidget {
  const Cadastro02Screen({super.key});

  @override
  State<Cadastro02Screen> createState() => _Cadastro02ScreenState();
}

class _Cadastro02ScreenState extends State<Cadastro02Screen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _enderecoService = EnderecoService();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController ufController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  String lastCepSearched = '';
  String? lastEnderecoSource; // 'cache' ou 'api'

  // Estados para feedback visual em tempo real
  bool cepValid = false;
  bool cepTouched = false;
  bool enderecoValid = false;
  bool enderecoTouched = false;
  bool numeroValid = false;
  bool numeroTouched = false;
  bool bairroValid = false;
  bool bairroTouched = false;
  
  // Dados do usuário vindos da tela anterior
  String? userId;
  String? nome;
  String? email;
  String? whatsapp;

  Future<void> buscarEndereco(String cep) async {
    setState(() { isLoading = true; });
    try {
      final endereco = await _enderecoService.buscarEnderecoPorCep(cep);
      if (!mounted) return;
      
      if (endereco != null) {
        setState(() {
          enderecoController.text = endereco.logradouro;
          bairroController.text = endereco.bairro;
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
          icon: Icons.error,
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

  @override
  void initState() {
    super.initState();
    cepController.addListener(_onCepChanged);
    
    // Recuperar dados passados da tela anterior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args != null) {
        setState(() {
          userId = args['userId'];
          nome = args['nome'];
          email = args['email'];
          whatsapp = args['whatsapp'];
        });
      }
    });
  }

  // Funções para validação em tempo real
  void _validarCepTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        cepValid = false;
        cepTouched = true;
      });
      return;
    }
    
    final isValid = Validators.cep(value) == null;
    setState(() {
      cepValid = isValid;
      cepTouched = true;
    });
  }

  void _validarEnderecoTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        enderecoValid = false;
        enderecoTouched = true;
      });
      return;
    }
    
    final isValid = value.trim().length >= 3;
    setState(() {
      enderecoValid = isValid;
      enderecoTouched = true;
    });
  }

  void _validarNumeroTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        numeroValid = false;
        numeroTouched = true;
      });
      return;
    }
    
    final isValid = value.trim().isNotEmpty;
    setState(() {
      numeroValid = isValid;
      numeroTouched = true;
    });
  }

  void _validarBairroTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        bairroValid = false;
        bairroTouched = true;
      });
      return;
    }
    
    final isValid = value.trim().length >= 2;
    setState(() {
      bairroValid = isValid;
      bairroTouched = true;
    });
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

  Future<bool> _onWillPop() async {
    final colorScheme = Theme.of(context).colorScheme;
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Cancelar cadastro'),
        content: const Text('Deseja realmente cancelar o cadastro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              backgroundColor: Colors.white,
            ),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: colorScheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Sim'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _salvarEndereco() async {
    if (!_formKey.currentState!.validate()) return;
    if (userId == null) {
      showAppSnackBar(
        context,
        'Erro: Dados do usuário não encontrados',
        icon: Icons.error,
        backgroundColor: Colors.red.shade600,
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      // Preparar dados do usuário para salvar no Firestore
      final enderecoMap = {
        'cep': cepController.text,
        'logradouro': enderecoController.text,
        'numero': numeroController.text,
        'bairro': bairroController.text,
        'complemento': complementoController.text,
        'uf': ufController.text,
      };
      final userData = {
        'nome': nome,
        'email': email,
        'whatsapp': whatsapp,
        'endereco': enderecoMap,
        'enderecos': [enderecoMap], // Salva também na lista
        'dataCadastro': DateTime.now().toIso8601String(),
        'ativo': true,
      };

      // Salvar dados do usuário no Firestore
      await _firestoreService.salvarUsuario(userId!, userData);
      // Atualizar cadastroCompleto para true
      await _firestoreService.salvarUsuario(userId!, {'cadastroCompleto': true});

      if (mounted) {
        showAppSnackBar(
          context,
          'Cadastro realizado com sucesso!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );

        // Navegar para a tela principal
        Navigator.pushReplacementNamed(context, '/splash_produtos');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao finalizar cadastro: $e',
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
    final double horizontalPadding = MediaQuery.of(context).size.width > 500 ? 120 : 32;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mercado Fácil'),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Cadastro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Passo 02 de 02',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                                child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: 'Carregando'),
                              ),
                            )
                          : cepTouched
                              ? Icon(
                                  cepValid ? Icons.check_circle : Icons.error,
                                  color: cepValid ? Colors.green : Colors.red,
                                )
                              : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cepTouched
                              ? (cepValid ? Colors.green : Colors.red)
                              : colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.cep,
                    onChanged: _validarCepTempoReal,
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
                            suffixIcon: enderecoTouched
                                ? Icon(
                                    enderecoValid ? Icons.check_circle : Icons.error,
                                    color: enderecoValid ? Colors.green : Colors.red,
                                  )
                                : null,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: enderecoTouched
                                    ? (enderecoValid ? Colors.green : Colors.red)
                                    : colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite o endereço';
                            }
                            return null;
                          },
                          onChanged: _validarEnderecoTempoReal,
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
                            suffixIcon: numeroTouched
                                ? Icon(
                                    numeroValid ? Icons.check_circle : Icons.error,
                                    color: numeroValid ? Colors.green : Colors.red,
                                  )
                                : null,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: numeroTouched
                                    ? (numeroValid ? Colors.green : Colors.red)
                                    : colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite o número';
                            }
                            return null;
                          },
                          onChanged: _validarNumeroTempoReal,
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
                            suffixIcon: bairroTouched
                                ? Icon(
                                    bairroValid ? Icons.check_circle : Icons.error,
                                    color: bairroValid ? Colors.green : Colors.red,
                                  )
                                : null,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: bairroTouched
                                    ? (bairroValid ? Colors.green : Colors.red)
                                    : colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite o bairro';
                            }
                            return null;
                          },
                          onChanged: _validarBairroTempoReal,
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
                              semanticsLabel: 'Carregando',
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
      ),
    );
  }
}