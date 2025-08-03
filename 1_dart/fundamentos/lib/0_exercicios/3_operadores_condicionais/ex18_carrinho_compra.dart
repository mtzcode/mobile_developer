// Crie um programa com:

// String nomeProduto = "Sabonete"
// int quantidade = 3
// double precoUnitario = 2.50
// Calcule o valor total da compra
// Se a quantidade for maior ou igual a 5 → aplique desconto de 10%

void main() {
  String nomeProduto = "Sabonete";
  int quantidade = 7;
  double precoUnitario = 2.50;
  double totalCompra = 0.0;
  double desconto = 0.0;

  totalCompra = quantidade * precoUnitario;

  if (quantidade >= 5) {
    desconto = totalCompra * 0.10;
    totalCompra -= desconto;
  }

  print("Produto: $nomeProduto");
  print("Quantidade itens: $quantidade x ${precoUnitario.toStringAsFixed(2)}");

  if (desconto > 0) {
    print("Desconto aplicado: R\$${desconto.toStringAsFixed(2)}");
    print("Total da compra com desconto: R\$${totalCompra.toStringAsFixed(2)}");
  } else {
    print("Total da compra: ${totalCompra.toStringAsFixed(2)}");
  }
}
