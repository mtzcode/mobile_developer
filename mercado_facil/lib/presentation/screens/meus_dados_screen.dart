import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../data/services/user_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_utils.dart';

class MeusDadosScreen extends StatefulWidget {
  const MeusDadosScreen({super.key});

  @override
  State<MeusDadosScreen> createState() => _MeusDadosScreenState();
}

class _MeusDadosScreenState extends State<MeusDadosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController senhaAtualController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  bool _mostrarAlterarSenha = false;
  bool _isLoading = false;

  // Estados para feedback visual em tempo real
  bool nomeValid = false;
  bool nomeTouched = false;
  bool emailValid = false;
  bool emailTouched = false;
  bool whatsappValid = false;
  bool whatsappTouched = false;
  bool novaSenhaValid = false;
  bool novaSenhaTouched = false;
  bool confirmarSenhaValid = false;
  bool confirmarSenhaTouched = false;

  File? _foto;
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.carregarUsuarioLogado();
    
    final usuario = userProvider.usuarioLogado;
    if (usuario != null) {
      setState(() {
        nomeController.text = usuario.nome;
        emailController.text = usuario.email;
        whatsappController.text = usuario.whatsapp;
        _fotoUrl = usuario.fotoUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _foto = File(pickedFile.path);
        _fotoUrl = null;
      });
    }
  }

  // Funções para validação em tempo real
  void _validarNomeTempoReal(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() {
        nomeValid = false;
        nomeTouched = true;
      });
      return;
    }
    
    final isValid = value.trim().length >= 3;
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

  void _validarNovaSenhaTempoReal(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        novaSenhaValid = false;
        novaSenhaTouched = true;
      });
      return;
    }
    
    final isValid = Validators.senha(value) == null;
    setState(() {
      novaSenhaValid = isValid;
      novaSenhaTouched = true;
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
    
    final isValid = value == novaSenhaController.text;
    setState(() {
      confirmarSenhaValid = isValid;
      confirmarSenhaTouched = true;
    });
  }

  Future<void> _salvarDados() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final dadosAtualizados = {
        'nome': nomeController.text.trim(),
        'email': emailController.text.trim(),
        'whatsapp': whatsappController.text.trim(),
        'dataAtualizacao': DateTime.now().toIso8601String(),
      };
      
      await userProvider.atualizarDadosUsuario(dadosAtualizados);
      
      if (mounted) {
        showAppSnackBar(
          context,
          'Dados atualizados com sucesso!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao atualizar dados: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Dados'),
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
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _foto != null
                            ? FileImage(_foto!)
                            : (_fotoUrl != null ? NetworkImage(_fotoUrl!) : null) as ImageProvider?,
                        backgroundColor: Colors.grey[200],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite seu nome';
                    }
                    return null;
                  },
                  onChanged: _validarNomeTempoReal,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  validator: Validators.email,
                  onChanged: _validarEmailTempoReal,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: whatsappController,
                  decoration: InputDecoration(
                    labelText: 'WhatsApp',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  validator: Validators.telefone,
                  onChanged: _validarWhatsAppTempoReal,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarAlterarSenha = !_mostrarAlterarSenha;
                            if (!_mostrarAlterarSenha) {
                              senhaAtualController.clear();
                              novaSenhaController.clear();
                              confirmarSenhaController.clear();
                            }
                          });
                        },
                        child: Text(_mostrarAlterarSenha ? 'Cancelar alteração' : 'Alterar senha'),
                      ),
                    ),
                  ],
                ),
                if (_mostrarAlterarSenha) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: senhaAtualController,
                    decoration: InputDecoration(
                      labelText: 'Senha atual',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite sua senha atual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: novaSenhaController,
                    decoration: InputDecoration(
                      labelText: 'Nova senha',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: novaSenhaTouched
                          ? Icon(
                              novaSenhaValid ? Icons.check_circle : Icons.error,
                              color: novaSenhaValid ? Colors.green : Colors.red,
                            )
                          : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: novaSenhaTouched
                              ? (novaSenhaValid ? Colors.green : Colors.red)
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
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite a nova senha';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                    onChanged: _validarNovaSenhaTempoReal,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmarSenhaController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nova senha',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: confirmarSenhaTouched
                          ? Icon(
                              confirmarSenhaValid ? Icons.check_circle : Icons.error,
                              color: confirmarSenhaValid ? Colors.green : Colors.red,
                            )
                          : null,
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
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme a nova senha';
                      }
                      if (value != novaSenhaController.text) {
                        return 'Senhas não coincidem';
                      }
                      return null;
                    },
                    onChanged: _validarConfirmarSenhaTempoReal,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _salvarDados,
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Salvar dados'),
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