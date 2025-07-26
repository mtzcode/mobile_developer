// 9.Crie uma função chamada apresentar() que usa variáveis locais: nome, idade e altura, e retorna uma apresentação completa em String.

String apresentar() {
  var nome = "Pabllo";
  var idade = 32;
  var altura = 1.65;
  return "Olá, meu nome é $nome, tenho $idade anos e tenho $altura m de altura.";
}

void main() {
  print(apresentar());
}