// Crie um programa que:

// Mostra o nome do sistema (usando const)
// Gera o número da nota com DateTime.now().millisecondsSinceEpoch

// Verifica o valor total da compra:
// Acima de R$ 100 → aplica 10% de desconto
// Entre R$ 50 e R$ 100 → aplica 5%
// Abaixo de R$ 50 → sem desconto

void main() {
  const nomeSistema = "NotaFácil";
  final numNota = DateTime.now().millisecondsSinceEpoch;
  var vlCompra = 150;
  var desconto = 0.0;
  var vlFinal = 0.0;

  if (vlCompra > 100) {
    desconto = vlCompra * 0.10;
  } else if (vlCompra >= 50) {
    desconto = vlCompra * 0.05;
  }

  vlFinal = vlCompra - desconto;

  print("Sistema: $nomeSistema");
  print("Número da nota: $numNota");
  print("Valor original: R\$${vlCompra.toStringAsFixed(2)}");

  if (desconto == 0) {
    print("Desconto aplicado: Sem desconto");
  } else {
    print("Desconto aplicado: R\$${desconto.toStringAsFixed(2)}");
  }
  print("Valor final: R\$${vlFinal.toStringAsFixed(2)}");
}
