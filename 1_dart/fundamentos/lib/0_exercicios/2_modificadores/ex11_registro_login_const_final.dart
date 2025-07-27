// 11.Informações de um sistema de login
// Um sistema de login precisa exibir o nome do app, que nunca muda, e a data/hora em que o usuário acessou.

// Objetivo:
// Use const para o nome do aplicativo.
// Use final para registrar o horário do login com DateTime.now()
// Mostre as duas informações no console.

void main() {
  const nomeApp = "Registro de Login";
  final horaAtual = DateTime.now();

  print("=======| $nomeApp |======= ");
  print("Último login: ${horaAtual.day}/${horaAtual.month}/${horaAtual.year} | ${horaAtual.hour}:${horaAtual.minute}:${horaAtual.second}");
}
