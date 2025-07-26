// // 1.Crie variáveis do tipo int, double, String
// //e bool com valores quaisquer e imprima seus conteúdos no console.
void main() {
  int numPdv = 101;
  double fechamentoCaixa = 2356.90;
  String nomeOperador = "João";
  bool caixaBateu = !true;

  print("Número PDV: $numPdv");
  print("Operador: $nomeOperador");
  print("Fechamento: R\$${fechamentoCaixa.toStringAsFixed(2)}");
  print("Caixa bateu: $caixaBateu");
}
