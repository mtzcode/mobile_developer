// 10.Crie um programa que simula um usuário com as seguintes variáveis:

// String nome
// int? idade
// bool? possuiCadastro

// Use ?? para mostrar mensagens como:

// "Usuário sem idade informada"
// "Cadastro pendente" se possuiCadastro for null

late String nome;
int? idade;
bool? possuiCadastro;
void main() {
  nome = "Pabllo";

  print(nome);
  print(idade ?? "Usuário sem idade informada");
  print(possuiCadastro ?? "Cadastro pendente");
}
