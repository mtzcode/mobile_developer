// Testando const vs final - Diferenças importantes

void main() {
  // ===== CONST - Deve ser inicializada na declaração =====
  const meuApp = "meuApp"; // ✅ Correto - const sempre inicializada
  print("Const: $meuApp");

  // ❌ ERRO: const não pode ser declarada sem inicialização
  // const meuApp2;
  // meuApp2 = "teste"; // Não funciona!

  // ===== FINAL - Também deve ser inicializada na declaração =====
  final data = DateTime.now(); // ✅ Correto - final inicializada
  print("Final: $data");

  // ❌ ERRO: final também não pode ser declarada sem inicialização
  // final data2;
  // data2 = DateTime.now(); // Não funciona!

  // ===== VAR - Pode ser inicializada depois =====
  var contador; // ✅ Pode ser declarada sem inicialização
  contador = 0; // ✅ Pode ser atribuída depois
  contador = 1; // ✅ Pode ser reatribuída
  print("Var: $contador");

  // ===== RESUMO DAS DIFERENÇAS =====
  print("\n=== DIFERENÇAS ===");
  print("const: SEMPRE inicializada na declaração");
  print("final: SEMPRE inicializada na declaração");
  print("var: pode ser inicializada depois e reatribuída");
}

/*
IMPORTANTE:
- const e final AMBAS precisam ser inicializadas na declaração
- A diferença é QUANDO o valor é conhecido:
  * const: valor conhecido em tempo de compilação
  * final: valor pode ser calculado em tempo de execução
- Apenas var permite declaração sem inicialização
*/
