// Simule uma tela de login:
// Use uma variável usuarioLogado = false
// Use if para mostrar:
// “Acesso permitido” se true
// “Usuário não logado” se false
// Mostre também a hora atual (DateTime.now()) do acesso (ou tentativa)

void main() {
  var usuarioLogado = false;
  var horaAcesso = DateTime.now();

  if (usuarioLogado == true) {
    print("Acesso permitido.");
  } else {
    print("Acesso negado.");
  }
  print(
    "Horário de Acesso /Tentativa: ${horaAcesso.day}/${horaAcesso.month.toString().padLeft(2, '0')}/${horaAcesso.year} ${horaAcesso.hour}:${horaAcesso.minute}:${horaAcesso.second}",
  );
}
