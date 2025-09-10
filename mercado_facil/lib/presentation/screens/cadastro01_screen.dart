import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/datasources/firestore_auth_service.dart';
import '../../core/utils/validators.dart';

class Cadastro01Screen extends StatefulWidget {
  const Cadastro01Screen({super.key});

  @override
  State<Cadastro01Screen> createState() => _Cadastro01ScreenState();
}

class _Cadastro01ScreenState extends State<Cadastro01Screen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = FirestoreAuthService();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();

  String nome = '';
  String email = '';
  String whatsapp = '';
  String senha = '';
  String confirmarSenha = '';
  bool obscureSenha = true;
  bool obscureConfirmarSenha = true;
  bool isLoading = false;

  // Estados para feedback visual em tempo real
  bool nomeValid = false;
  bool nomeTouched = false;
  bool emailValid = false;
  bool emailTouched = false;
  bool whatsappValid = false;
  bool whatsappTouched = false;
  bool senhaValid = false;
  bool senhaTouched = false;
  bool confirmarSenhaValid = false;
  bool confirmarSenhaTouched = false;

  // Regex para validações removidas (não utilizadas)

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    whatsappController.dispose();
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

  // Validar força da senha


  // Funções para validação em tempo real
  void _validarNomeTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        nomeValid = false;
        nomeTouched = true;
      });
      return;
    }
    
    final isValid = value.trim().split(' ').length >= 2 && value.trim().length >= 3;
    setState(() {
      nomeValid = isValid;
      nomeTouched = true;
    });
  }

  void _validarEmailTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        emailValid = false;
        emailTouched = true;
      });
      return;
    }
    
    final isValid = Validators.email(value) == null;
    setState(() {
      emailValid = isValid;
      emailTouched = true;
    });
  }

  void _validarWhatsAppTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        whatsappValid = false;
        whatsappTouched = true;
      });
      return;
    }
    
    final isValid = Validators.telefone(value) == null;
    setState(() {
      whatsappValid = isValid;
      whatsappTouched = true;
    });
  }

  void _validarSenhaTempoReal(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        senhaValid = false;
        senhaTouched = true;
      });
      return;
    }
    
    final isValid = Validators.senha(value) == null;
    setState(() {
      senhaValid = isValid;
      senhaTouched = true;
    });
  }

  void _validarConfirmarSenhaTempoReal(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        confirmarSenhaValid = false;
        confirmarSenhaTouched = true;
      });
      return;
    }
    
    final isValid = value == senha;
    setState(() {
      confirmarSenhaValid = isValid;
      confirmarSenhaTouched = true;
    });
  }

  // Formatar WhatsApp
  String _formatarWhatsApp(String value) {
    // Remove tudo que não é número
    String numeros = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numeros.length <= 2) {
      return numeros;
    } else if (numeros.length <= 6) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2)}';
    } else if (numeros.length <= 10) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    } else {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7, 11)}';
    }
  }

  Future<void> _proximoPasso() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => isLoading = true);

    try {
      // Criar usuário no Firestore
      final usuario = await _authService.registrarUsuario(
        nome: nome,
        email: email.trim(),
        whatsapp: whatsapp,
        senha: senha,
      );
      
      if (mounted) {
        // Navegar para a próxima tela, passando os dados
        Navigator.pushNamed(context, '/cadastro02', arguments: {
          'userId': usuario.id,
          'nome': nome,
          'email': email,
          'whatsapp': whatsapp,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
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
          title: const Text('Cadastro'),
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
                    'Passo 01 de 02',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Campo Nome
                  TextFormField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome completo',
                      hintText: 'Digite seu nome completo',
                      labelStyle: TextStyle(color: colorScheme.tertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: nomeTouched
                          ? Icon(
                              nomeValid ? Icons.check_circle : Icons.error,
                              color: nomeValid ? Colors.green : Colors.red,
                            )
                          : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: nomeTouched
                              ? (nomeValid ? Colors.green : Colors.red)
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
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite seu nome completo';
                      }
                      if (value.trim().split(' ').length < 2) {
                        return 'Digite seu nome completo (nome e sobrenome)';
                      }
                      if (value.trim().length < 3) {
                        return 'Nome muito curto';
                      }
                      return null;
                    },
                    onChanged: _validarNomeTempoReal,
                    onSaved: (value) => nome = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 16),
                  // Campo Email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'exemplo@email.com',
                      labelStyle: TextStyle(color: colorScheme.tertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: emailTouched
                          ? Icon(
                              emailValid ? Icons.check_circle : Icons.error,
                              color: emailValid ? Colors.green : Colors.red,
                            )
                          : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: emailTouched
                              ? (emailValid ? Colors.green : Colors.red)
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
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: Validators.email,
                    onChanged: _validarEmailTempoReal,
                    onSaved: (value) => email = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 16),
                  // Campo WhatsApp
                  TextFormField(
                    controller: whatsappController,
                    decoration: InputDecoration(
                      labelText: 'WhatsApp',
                      hintText: '(11) 99999-9999',
                      labelStyle: TextStyle(color: colorScheme.tertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: whatsappTouched
                          ? Icon(
                              whatsappValid ? Icons.check_circle : Icons.error,
                              color: whatsappValid ? Colors.green : Colors.red,
                            )
                          : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: whatsappTouched
                              ? (whatsappValid ? Colors.green : Colors.red)
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
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: Validators.telefone,
                    onChanged: (value) {
                      setState(() {
                        whatsapp = _formatarWhatsApp(value);
                      });
                      _validarWhatsAppTempoReal(value);
                    },
                    onSaved: (value) => whatsapp = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 16),
                  // Campo Senha
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: 'Crie uma senha forte',
                      labelStyle: TextStyle(color: colorScheme.tertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (senhaTouched)
                            Icon(
                              senhaValid ? Icons.check_circle : Icons.error,
                              color: senhaValid ? Colors.green : Colors.red,
                            ),
                          IconButton(
                            icon: Icon(
                              obscureSenha ? Icons.visibility : Icons.visibility_off,
                              color: colorScheme.tertiary,
                              semanticLabel: obscureSenha ? 'Mostrar senha' : 'Ocultar senha',
                            ),
                            onPressed: () {
                              setState(() {
                                obscureSenha = !obscureSenha;
                              });
                            },
                          ),
                        ],
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: senhaTouched
                              ? (senhaValid ? Colors.green : Colors.red)
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
                    obscureText: obscureSenha,
                    validator: Validators.senha,
                    onChanged: (value) {
                      senha = value;
                      _validarSenhaTempoReal(value);
                    },
                    onSaved: (value) => senha = value ?? '',
                  ),
                  const SizedBox(height: 8),
                  // Dicas de senha
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sua senha deve conter:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Pelo menos 8 caracteres\n• Pelo menos 3 tipos: maiúscula, minúscula, número, especial',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo Confirmar Senha
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      hintText: 'Digite a senha novamente',
                      labelStyle: TextStyle(color: colorScheme.tertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (confirmarSenhaTouched)
                            Icon(
                              confirmarSenhaValid ? Icons.check_circle : Icons.error,
                              color: confirmarSenhaValid ? Colors.green : Colors.red,
                            ),
                          IconButton(
                            icon: Icon(
                              obscureConfirmarSenha ? Icons.visibility : Icons.visibility_off,
                              color: colorScheme.tertiary,
                              semanticLabel: obscureConfirmarSenha ? 'Mostrar senha' : 'Ocultar senha',
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmarSenha = !obscureConfirmarSenha;
                              });
                            },
                          ),
                        ],
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: confirmarSenhaTouched
                              ? (confirmarSenhaValid ? Colors.green : Colors.red)
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
                    obscureText: obscureConfirmarSenha,
                    onChanged: (value) {
                      confirmarSenha = value;
                      _validarConfirmarSenhaTempoReal(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme sua senha';
                      }
                      if (value != senha) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                    onSaved: (value) => confirmarSenha = value ?? '',
                  ),
                  const SizedBox(height: 24),
                  // Botão Próximo
                  ElevatedButton(
                    onPressed: isLoading ? null : _proximoPasso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              semanticsLabel: 'Carregando',
                            ),
                          )
                        : const Text(
                            'Próximo',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}