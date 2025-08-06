// Crie uma variável double preco = 120.0;
// Use ternário para mostrar:
// “Desconto de 10% aplicado” se o valor for maior ou igual a 100
// “Sem desconto” caso contrário

void main() {
  final double preco = 120.0;
  String precofinal = preco >= 100
      ? "Desconto de 10% aplicado"
      : "Sem desconto";

  print(precofinal);
}
