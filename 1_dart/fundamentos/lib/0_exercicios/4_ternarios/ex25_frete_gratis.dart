// Crie uma variável double valorCompra = 65.0;
// Use ternário para imprimir:
// “Você ganhou frete grátis!” se a compra for maior ou igual a 60
// “Frete: R$9.90” se for menor

void main() {
  final double valorCompra = 59.0;
  String resultadoCompra = valorCompra >= 60
      ? "Você ganhou frete grátis!"
      : "Frete R\$9.90";

  print(resultadoCompra);
}
