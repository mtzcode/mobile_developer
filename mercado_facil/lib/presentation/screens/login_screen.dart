import 'package:flutter/material.dart';
import '../../data/datasources/firestore_auth_service.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String senha = '';
  bool obscureText = true;
  bool isLoading = false;
  final _authService = FirestoreAuthService();

  // Estados para feedback visual em tempo real
  bool emailValid = false;
  bool emailTouched = false;
  bool senhaValid = false;
  bool senhaTouched = false;

  // Função para validar email em tempo real
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

  // Função para validar senha em tempo real
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => isLoading = true);
    
    try {
      await _authService.fazerLogin(email.trim(), senha);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/splash_produtos');
      }
    } catch (e) {
      if (mounted) {
        String mensagemErro = 'Erro ao fazer login';
        
        // Tratamento específico de erros do Firebase
        if (e.toString().contains('user-not-found')) {
          mensagemErro = 'Usuário não encontrado. Verifique seu e-mail.';
        } else if (e.toString().contains('wrong-password')) {
          mensagemErro = 'Senha incorreta. Tente novamente.';
        } else if (e.toString().contains('invalid-email')) {
          mensagemErro = 'E-mail inválido.';
        } else if (e.toString().contains('user-disabled')) {
          mensagemErro = 'Conta desabilitada. Entre em contato com o suporte.';
        } else if (e.toString().contains('too-many-requests')) {
          mensagemErro = 'Muitas tentativas. Tente novamente em alguns minutos.';
        } else if (e.toString().contains('network')) {
          mensagemErro = 'Erro de conexão. Verifique sua internet.';
        }
        
        showAppSnackBar(
          context,
          mensagemErro,
          icon: Icons.error,
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _recuperarSenha() async {
    Navigator.pushNamed(context, '/redefinir_senha');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double horizontalPadding = MediaQuery.of(context).size.width > 500 ? 120 : 32;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo e header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      // Logo do app
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Título principal
                      Text(
                        'Mercado Fácil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtítulo
                      Text(
                        'Seu supermercado online',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Campo Email
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'exemplo@email.com',
                      labelStyle: TextStyle(color: colorScheme.tertiary),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      suffixIcon: emailTouched
                          ? Icon(
                              emailValid ? Icons.check_circle : Icons.error,
                              color: emailValid ? Colors.green : Colors.red,
                            )
                          : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: emailTouched
                              ? (emailValid ? Colors.green : Colors.red)
                              : colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: Validators.email,
                    onChanged: _validarEmailTempoReal,
                    onSaved: (value) => email = value?.trim() ?? '',
                  ),
                ),
                const SizedBox(height: 16),
                // Campo Senha
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: 'Sua senha',
                      labelStyle: TextStyle(color: colorScheme.tertiary),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
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
                              obscureText ? Icons.visibility_off : Icons.visibility,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                              semanticLabel: obscureText ? 'Mostrar senha' : 'Ocultar senha',
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ],
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: senhaTouched
                              ? (senhaValid ? Colors.green : Colors.red)
                              : colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    obscureText: obscureText,
                    validator: Validators.senha,
                    onChanged: _validarSenhaTempoReal,
                    onSaved: (value) => senha = value ?? '',
                  ),
                ),
                const SizedBox(height: 8),
                // Link Esqueceu a senha
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: isLoading ? null : _recuperarSenha,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Entrar
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              semanticsLabel: 'Carregando',
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                // Divisor
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              colorScheme.tertiary.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          color: colorScheme.tertiary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              colorScheme.tertiary.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Botão Cadastrar
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () {
                      Navigator.pushNamed(context, '/cadastro01');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Criar nova conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}