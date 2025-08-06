// Crie uma variável bool estaLogado = false;
// Use ternário para imprimir:
// “Bem-vindo de volta!” se true
// “Faça login para continuar” se false

void main() {
  final bool estaLogado = false;
  String status = estaLogado == true
      ? "Bem-vindo de volta!"
      : "Faça login para continuar";

  print(status);
}
