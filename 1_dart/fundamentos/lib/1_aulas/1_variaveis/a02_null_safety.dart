//Como permitir que a variável possa ser nula
void main() {
  String nome = "Lucas"; //Variável foi atruibuida um valor inicial
  String? apelido; //Variáve/ foi iniciada sem valor (Null)

  print("Nome: $nome");
  print("Apelido: ${apelido ?? 'sem apelido'}");

 //Operador de acesso seguro:

String? cidade;
// ignore: dead_code
print(cidade?.toUpperCase()); // Não dá erro, apenas imprime null

//Operador de valor padrão: ??
String? nome2;
print(nome2 ?? "Desconhecido"); // imprime "Desconhecido"

//Operador de asserção ! (use com cuidado!)
String? nome3 = "Carlos";
print(nome3.length); // OK

String? nome4;
print(nome4!.length); // ERRO em tempo de execução
}

//- `null` = valor nulo (caixa vazia)
//- Variáveis **sem `?` não aceitam null**
//- Use `?` para permitir null: `String? nome`
//- Use `?.` para acessar algo com segurança
//- Use `??` para fornecer um valor padrão
//- Use `!` só quando tiver certeza de que **não é null**

