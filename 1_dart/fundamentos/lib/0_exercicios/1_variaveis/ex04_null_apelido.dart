// Null Safety em Dart - Como trabalhar com valores nulos
//
// Null Safety é um recurso que previne erros relacionados a valores nulos
// em tempo de compilação, tornando o código mais seguro.

void main() {
  // ===== VARIÁVEIS NÃO-NULAS vs NULAS =====

  // Variável NÃO pode ser nula (null safety padrão)
  String nome = "Lucas"; // ✅ Correto - valor inicial atribuído
  // String nome2 = null; // ❌ ERRO - variável não aceita null

  // Variável PODE ser nula (usando ?)
  String? apelido; // ✅ Correto - inicializada como null
  // ignore: unused_local_variable
  String? cidade; // ✅ Também correto - explicitamente null

  print("Nome: $nome");
  print("Apelido: ${apelido ?? 'sem apelido'}");

  // ===== OPERADORES DE NULL SAFETY =====

  // 1. Operador de acesso seguro (?.) - não causa erro se for null
  String? cidade2;
  // ignore: dead_code
  print(cidade2?.toUpperCase()); // ✅ Imprime null (sem erro)

  // Comparação com acesso direto (que causaria erro):
  // print(cidade2.toUpperCase()); // ❌ ERRO em tempo de execução

  // 2. Operador de valor padrão (??) - fornece valor alternativo
  String? nome2;
  print(nome2 ?? "Desconhecido"); // ✅ Imprime "Desconhecido"

  // 3. Operador de asserção (!) - "garante" que não é null (use com cuidado!)
  String? nome3 = "Carlos";
  print(nome3.length); // ✅ OK - sabemos que não é null

  // CUIDADO: Se for null, causa erro em tempo de execução
  // ignore: unused_local_variable
  String? nome4;
  // print(nome4!.length); // ❌ ERRO em tempo de execução - crash!

  // ===== RESUMO DOS CONCEITOS =====
  print("\n=== RESUMO ===");
  print("- null = valor nulo (caixa vazia)");
  print("- Variáveis SEM ? não aceitam null");
  print("- Use ? para permitir null: String? nome");
  print("- Use ?. para acessar com segurança");
  print("- Use ?? para fornecer valor padrão");
  print("- Use ! só quando tiver CERTEZA de que não é null");
}

/*
DICA IMPORTANTE:
- Prefira sempre usar ?. e ?? em vez de !
- O operador ! só deve ser usado quando você tem 100% de certeza
- Null Safety torna seu código mais seguro e previne muitos bugs!
*/
