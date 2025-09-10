class Usuario {
  final String id;
  final String nome;
  final String email;
  final String whatsapp;
  final String senhaHash; // Senha criptografada
  final Map<String, dynamic>? endereco;
  final List<Map<String, dynamic>>? enderecos;
  final String? fotoUrl;
  final DateTime dataCadastro;
  final bool ativo;
  final bool cadastroCompleto;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.whatsapp,
    required this.senhaHash,
    this.endereco,
    this.enderecos,
    this.fotoUrl,
    required this.dataCadastro,
    this.ativo = true,
    this.cadastroCompleto = false,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'whatsapp': whatsapp,
      'senhaHash': senhaHash,
      'endereco': endereco,
      'enderecos': enderecos,
      'fotoUrl': fotoUrl,
      'dataCadastro': dataCadastro.toIso8601String(),
      'ativo': ativo,
      'cadastroCompleto': cadastroCompleto,
    };
  }

  // Criar a partir de Map (do Firestore)
  factory Usuario.fromMap(String id, Map<String, dynamic> map) {
    return Usuario(
      id: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      senhaHash: map['senhaHash'] ?? '',
      endereco: map['endereco'],
      enderecos: map['enderecos'] != null 
          ? List<Map<String, dynamic>>.from(map['enderecos'])
          : null,
      fotoUrl: map['fotoUrl'],
      dataCadastro: DateTime.parse(map['dataCadastro'] ?? DateTime.now().toIso8601String()),
      ativo: map['ativo'] ?? true,
      cadastroCompleto: map['cadastroCompleto'] ?? false,
    );
  }

  // Copiar com alterações
  Usuario copyWith({
    String? nome,
    String? email,
    String? whatsapp,
    String? senhaHash,
    Map<String, dynamic>? endereco,
    List<Map<String, dynamic>>? enderecos,
    String? fotoUrl,
    bool? ativo,
    bool? cadastroCompleto,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      senhaHash: senhaHash ?? this.senhaHash,
      endereco: endereco ?? this.endereco,
      enderecos: enderecos ?? this.enderecos,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      dataCadastro: dataCadastro,
      ativo: ativo ?? this.ativo,
      cadastroCompleto: cadastroCompleto ?? this.cadastroCompleto,
    );
  }
} 