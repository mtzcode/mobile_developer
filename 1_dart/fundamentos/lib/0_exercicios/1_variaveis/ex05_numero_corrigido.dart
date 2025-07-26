// 5.Crie uma variável int? numero que recebe null. Em seguida, use ?? para atribuir um valor padrão 0 em outra variável chamada numeroCorrigido. Imprima o resultado.

void main() {
  int? numero;
  var numeroCorrigido = numero ?? 0;

  print(numeroCorrigido);
}