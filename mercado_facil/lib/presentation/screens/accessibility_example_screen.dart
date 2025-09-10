import 'package:flutter/material.dart';
import '../widgets/accessibility_widgets.dart';
import '../widgets/keyboard_navigation.dart';
import '../widgets/screen_reader_labels.dart';

/// Tela de exemplo mostrando como implementar acessibilidade
class AccessibilityExampleScreen extends StatefulWidget {
  const AccessibilityExampleScreen({super.key});

  @override
  State<AccessibilityExampleScreen> createState() => _AccessibilityExampleScreenState();
}

class _AccessibilityExampleScreenState extends State<AccessibilityExampleScreen> 
    with AccessibilityMixin, KeyboardNavigationMixin {
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  double _sliderValue = 50.0;
  bool _switchValue = false;
  bool _checkboxValue = false;

  @override
  List<String> get focusableIds => [
    'email-field',
    'password-field',
    'show-password-toggle',
    'slider',
    'switch-toggle',
    'checkbox',
    'login-button',
    'register-button',
    'forgot-password-link',
  ];

  @override
  Widget build(BuildContext context) {
    return wrapWithKeyboardNavigation(
      Scaffold(
        appBar: AppBar(
          title: Semantics(
            header: true,
            child: const Text('Exemplo de Acessibilidade'),
          ),
          leading: AccessibilityWidgets.accessibleButton(
            label: ScreenReaderLabels.backButton,
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título da seção
              Semantics(
                header: true,
                child: Text(
                  'Formulário de Login',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),

              // Campo de e-mail
              KeyboardFocusable(
                id: 'email-field',
                onActivate: () => _focusEmailField(),
                child: AccessibilityWidgets.accessibleTextField(
                  label: ScreenReaderLabels.emailField,
                  controller: _emailController,
                  hint: 'Digite seu e-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ScreenReaderLabels.requiredField;
                    }
                    if (!value.contains('@')) {
                      return ScreenReaderLabels.invalidEmail;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Campo de senha
              KeyboardFocusable(
                id: 'password-field',
                onActivate: () => _focusPasswordField(),
                child: AccessibilityWidgets.accessibleTextField(
                  label: ScreenReaderLabels.passwordField,
                  controller: _passwordController,
                  hint: 'Digite sua senha',
                  isPassword: !_showPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ScreenReaderLabels.requiredField;
                    }
                    if (value.length < 6) {
                      return ScreenReaderLabels.weakPassword;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Toggle para mostrar senha
              KeyboardFocusable(
                id: 'show-password-toggle',
                onActivate: () => _togglePasswordVisibility(),
                child: AccessibilityWidgets.accessibleCheckbox(
                  label: 'Mostrar senha',
                  value: _showPassword,
                  onChanged: (value) => _togglePasswordVisibility(),
                ),
              ),
              const SizedBox(height: 24),

              // Seção de controles
              Semantics(
                header: true,
                child: Text(
                  'Controles de Exemplo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),

              // Slider
              KeyboardFocusable(
                id: 'slider',
                onActivate: () => _announceSliderValue(),
                child: AccessibilityWidgets.accessibleSlider(
                  label: 'Valor do slider',
                  value: _sliderValue,
                  onChanged: (value) => setState(() => _sliderValue = value),
                  min: 0,
                  max: 100,
                  divisions: 10,
                  hint: 'Deslize para ajustar o valor',
                ),
              ),
              const SizedBox(height: 16),

              // Switch
              KeyboardFocusable(
                id: 'switch-toggle',
                onActivate: () => _toggleSwitch(),
                child: AccessibilityWidgets.accessibleSwitch(
                  label: 'Ativar notificações',
                  value: _switchValue,
                  onChanged: (value) => _toggleSwitch(),
                  hint: 'Alternar para ativar ou desativar notificações',
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox
              KeyboardFocusable(
                id: 'checkbox',
                onActivate: () => _toggleCheckbox(),
                child: AccessibilityWidgets.accessibleCheckbox(
                  label: 'Aceitar termos de uso',
                  value: _checkboxValue,
                  onChanged: (value) => _toggleCheckbox(),
                  hint: 'Marque para aceitar os termos de uso',
                ),
              ),
              const SizedBox(height: 32),

              // Botões de ação
              KeyboardFocusable(
                id: 'login-button',
                onActivate: () => _performLogin(),
                child: AccessibilityWidgets.accessibleButton(
                  label: 'Fazer login',
                  onPressed: _isLoading ? () {} : () => _performLogin(),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: null, // Sobrescrito pelo AccessibilityWidgets
                      child: _isLoading
                          ? AccessibilityWidgets.accessibleLoading(
                              message: ScreenReaderLabels.getLoadingLabel('login'),
                            )
                          : const Text('Entrar'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              KeyboardFocusable(
                id: 'register-button',
                onActivate: () => _navigateToRegister(),
                child: AccessibilityWidgets.accessibleButton(
                  label: 'Criar conta',
                  onPressed: _navigateToRegister,
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: null, // Sobrescrito pelo AccessibilityWidgets
                      child: const Text('Criar Conta'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Link de recuperação de senha
              KeyboardFocusable(
                id: 'forgot-password-link',
                onActivate: () => _navigateToPasswordReset(),
                child: AccessibilityWidgets.accessibleButton(
                  label: 'Esqueci minha senha',
                  onPressed: _navigateToPasswordReset,
                  child: TextButton(
                    onPressed: null, // Sobrescrito pelo AccessibilityWidgets
                    child: const Text('Esqueci minha senha'),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Seção de informações
              AccessibilityWidgets.accessibleCard(
                label: 'Informações de acessibilidade',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Recursos de Acessibilidade',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AccessibilityWidgets.accessibleText(
                        text: '• Navegação por teclado (Tab, Enter, Setas)',
                        label: 'Navegação por teclado disponível',
                      ),
                      AccessibilityWidgets.accessibleText(
                        text: '• Compatível com leitores de tela',
                        label: 'Suporte a leitores de tela',
                      ),
                      AccessibilityWidgets.accessibleText(
                        text: '• Alto contraste disponível',
                        label: 'Tema de alto contraste',
                      ),
                      AccessibilityWidgets.accessibleText(
                        text: '• Feedback tátil para ações',
                        label: 'Feedback tátil habilitado',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos de ação
  void _focusEmailField() {
    // Foco será gerenciado pelo KeyboardFocusable
    provideHapticFeedback(HapticFeedbackType.selection);
  }

  void _focusPasswordField() {
    provideHapticFeedback(HapticFeedbackType.selection);
  }

  void _togglePasswordVisibility() {
    setState(() => _showPassword = !_showPassword);
    provideHapticFeedback(HapticFeedbackType.light);
    announceForAccessibility(
      _showPassword 
          ? ScreenReaderLabels.accessibilityModeEnabled 
          : ScreenReaderLabels.accessibilityModeDisabled
    );
  }

  void _announceSliderValue() {
    announceForAccessibility('Valor do slider: ${_sliderValue.toInt()}');
  }

  void _toggleSwitch() {
    setState(() => _switchValue = !_switchValue);
    provideHapticFeedback(HapticFeedbackType.light);
    announceForAccessibility(
      _switchValue 
          ? 'Notificações ativadas' 
          : 'Notificações desativadas'
    );
  }

  void _toggleCheckbox() {
    setState(() => _checkboxValue = !_checkboxValue);
    provideHapticFeedback(HapticFeedbackType.selection);
    announceForAccessibility(
      _checkboxValue 
          ? 'Termos aceitos' 
          : 'Termos não aceitos'
    );
  }

  Future<void> _performLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      announceForAccessibility(ScreenReaderLabels.validationError);
      return;
    }

    setState(() => _isLoading = true);
    provideHapticFeedback(HapticFeedbackType.medium);

    // Simular login
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      announceForAccessibility(ScreenReaderLabels.success);
      provideHapticFeedback(HapticFeedbackType.heavy);
    }
  }

  void _navigateToRegister() {
    provideHapticFeedback(HapticFeedbackType.light);
    announceForAccessibility('Navegando para tela de cadastro');
    // Navigator.pushNamed(context, '/cadastro01');
  }

  void _navigateToPasswordReset() {
    provideHapticFeedback(HapticFeedbackType.light);
    announceForAccessibility('Navegando para recuperação de senha');
    // Navigator.pushNamed(context, '/redefinir_senha');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}