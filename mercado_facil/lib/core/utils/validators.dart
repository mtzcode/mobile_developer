class Validators {
  /// Valida e-mail com regex robusto
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail obrigatório';
    }
    // Regex mais rigoroso para e-mail
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    final trimmedValue = value.trim();
    
    // Verificações adicionais para emails inválidos
    if (!trimmedValue.contains('@')) {
      return 'E-mail inválido';
    }
    if (!trimmedValue.contains('.')) {
      return 'E-mail inválido';
    }
    if (trimmedValue.startsWith('@') || trimmedValue.endsWith('@')) {
      return 'E-mail inválido';
    }
    if (trimmedValue.startsWith('.') || trimmedValue.endsWith('.')) {
      return 'E-mail inválido';
    }
    if (trimmedValue.contains('..')) {
      return 'E-mail inválido';
    }
    
    if (!regex.hasMatch(trimmedValue)) {
      return 'E-mail inválido';
    }
    return null;
  }

  /// Valida senha forte (mínimo 8 caracteres, letra, número e caractere especial)
  static String? senha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha obrigatória';
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    }
    if (!RegExp(r'[!@#\$&*~%^()_+=\-]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  /// Valida CPF (formato e dígitos)
  static String? cpf(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CPF obrigatório';
    }
    final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }
    // Validação dos dígitos verificadores
    int calcDV(String str, int len) {
      int sum = 0;
      for (int i = 0; i < len; i++) {
        sum += int.parse(str[i]) * (len + 1 - i);
      }
      int dv = 11 - (sum % 11);
      return (dv >= 10) ? 0 : dv;
    }
    final dv1 = calcDV(cpf, 9);
    final dv2 = calcDV(cpf, 10);
    if (dv1 != int.parse(cpf[9]) || dv2 != int.parse(cpf[10])) {
      return 'CPF inválido';
    }
    return null;
  }

  /// Valida telefone brasileiro (com DDD)
  static String? telefone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone obrigatório';
    }
    final tel = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (tel.length < 10 || tel.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    if (!RegExp(r'^[1-9]{2}9?[0-9]{8}$').hasMatch(tel)) {
      return 'Telefone inválido';
    }
    return null;
  }

  /// Valida CEP brasileiro
  static String? cep(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CEP obrigatório';
    }
    final cep = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }
    // Verifica se contém apenas números
    if (!RegExp(r'^[0-9]{8}$').hasMatch(cep)) {
      return 'CEP inválido';
    }
    return null;
  }
} 