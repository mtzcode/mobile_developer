// 14.Cadastro de usuário
// Um formulário de cadastro possui:

// Nome do campo obrigatório
// Código de verificação gerado no momento do cadastro

// Objetivo:
// Crie uma variável const campoObrigatorio = "Nome Completo"
// Crie uma variável final codigoVerificacao e atribua com DateTime.now().millisecondsSinceEpoch

void main() {
  const campoObrigatorio = "Nome Completo";
  final codigoVerificacao = DateTime.now().millisecondsSinceEpoch;

  print("======| Cadastro de Usuário|====== ");
  print("$campoObrigatorio: ");
  print("Código de verificação: $codigoVerificacao");
}
