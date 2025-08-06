// Crie uma variável String? nome = "";
// Use um ternário para imprimir:
// “Nome obrigatório” se for null ou estiver vazio
// “Nome: <nome>`” caso contrário

void main() {
  String? nome = "";
  // ignore: unnecessary_null_comparison
  print((nome == null || nome.isEmpty) ? "Nome obrigatório" : "Nome: $nome");
}
