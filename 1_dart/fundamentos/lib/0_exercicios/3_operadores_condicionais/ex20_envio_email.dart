// Envio de email de confirmação
// Crie uma variável String? emailCliente
// Se for null ou vazia → “Email inválido. Confirmação não enviada.”
// Caso contrário → “Email de confirmação enviado para: <email>”

void main() {
  late String emailCliente = "";

  if (emailCliente.isEmpty) {
    print("Email inválido. Confirmação não enviada.");
  } else {
    print("Email de confirmação enviado para: $emailCliente");
  }
}

