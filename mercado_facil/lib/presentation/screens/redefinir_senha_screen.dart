import 'package:flutter/material.dart';
import '../../data/datasources/firestore_auth_service.dart';
import '../../core/utils/validators.dart';

class RedefinirSenhaScreen extends StatefulWidget {
  const RedefinirSenhaScreen({super.key});

  @override
  State<RedefinirSenhaScreen> createState() => _RedefinirSenhaScreenState();
}

class _RedefinirSenhaScreenState extends State<RedefinirSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool isLoading = false;
  final _authService = FirestoreAuthService();

  // Estados para feedback visual em tempo real
  bool emailValid = false;
  bool emailTouched = false;

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

  Future<void> _enviarEmailRecuperacao() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => isLoading = true);
    
    try {
      await _authService.enviarEmailRecuperacao(email.trim());
      
      if (mounted) {
        // Mostrar diálogo de sucesso
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Email enviado!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Um email de recuperação foi enviado para:'),
                const SizedBox(height: 8),
                Text(
                  email.trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar diálogo
                  Navigator.of(context).pop(); // Voltar para login
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String mensagemErro = 'Erro ao enviar email de recuperação';
        
        if (e.toString().contains('user-not-found')) {
          mensagemErro = 'E-mail não encontrado. Verifique se está correto.';
        } else if (e.toString().contains('invalid-email')) {
          mensagemErro = 'E-mail inválido.';
        } else if (e.toString().contains('network')) {
          mensagemErro = 'Erro de conexão. Verifique sua internet.';
        } else if (e.toString().contains('too-many-requests')) {
          mensagemErro = 'Muitas tentativas. Tente novamente em alguns minutos.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagemErro),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título
                Text(
                  'Esqueceu sua senha?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Descrição
                Text(
                  'Não se preocupe! Digite seu e-mail e enviaremos um link para você redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.tertiary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Campo Email
                TextFormField(
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
                const SizedBox(height: 32),
                
                // Botão Enviar
                ElevatedButton(
                  onPressed: isLoading ? null : _enviarEmailRecuperacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
                          ),
                        )
                      : const Text(
                          'Enviar Email de Recuperação',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 24),
                
                // Botão Voltar
                OutlinedButton(
                  onPressed: isLoading ? null : () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Informações adicionais
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Dicas importantes:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Verifique sua caixa de entrada e spam\n'
                        '• O link expira em 1 hora\n'
                        '• Se não receber, tente novamente em alguns minutos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                      ),
                    ],
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