class Endereco {
  final String id;
  final String cep;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;
  final DateTime dataCadastro;
  final int contadorUso; // Quantas vezes foi usado

  Endereco({
    required this.id,
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.dataCadastro,
    this.contadorUso = 1,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'dataCadastro': dataCadastro.toIso8601String(),
      'contadorUso': contadorUso,
    };
  }

  // Criar a partir de Map (do Firestore)
  factory Endereco.fromMap(String id, Map<String, dynamic> map) {
    return Endereco(
      id: id,
      cep: map['cep'] ?? '',
      logradouro: map['logradouro'] ?? '',
      bairro: map['bairro'] ?? '',
      cidade: map['cidade'] ?? '',
      uf: map['uf'] ?? '',
      dataCadastro: DateTime.parse(map['dataCadastro'] ?? DateTime.now().toIso8601String()),
      contadorUso: map['contadorUso'] ?? 1,
    );
  }

  // Criar a partir da API ViaCEP
  factory Endereco.fromViaCep(Map<String, dynamic> data, String cep) {
    return Endereco(
      id: '', // Será definido pelo Firestore
      cep: cep,
      logradouro: data['logradouro'] ?? '',
      bairro: data['bairro'] ?? '',
      cidade: data['localidade'] ?? '',
      uf: data['uf'] ?? '',
      dataCadastro: DateTime.now(),
      contadorUso: 1,
    );
  }

  // Copiar com alterações
  Endereco copyWith({
    String? id,
    String? cep,
    String? logradouro,
    String? bairro,
    String? cidade,
    String? uf,
    int? contadorUso,
  }) {
    return Endereco(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      dataCadastro: dataCadastro,
      contadorUso: contadorUso ?? this.contadorUso,
    );
  }

  // Formatar para exibição
  String get enderecoCompleto {
    return '$logradouro, $bairro, $cidade - $uf';
  }

  // Formatar CEP
  String get cepFormatado {
    if (cep.length == 8) {
      return '${cep.substring(0, 5)}-${cep.substring(5)}';
    }
    return cep;
  }
} 