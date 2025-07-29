// 2. Classificação de nota escolar
// Dada uma nota (double), classifique:
// Abaixo de 6 → “Reprovado”
// De 6 até 7.9 → “Recuperação”
// De 8 até 10 → “Aprovado com sucesso”

void main() {
  double nota = 3.5;

  if (nota < 6) {
    print("Nota final: $nota, aluno está reprovado!");
  } else if (nota >= 6 && nota <= 7.9) {
    print("Nota final: $nota, aluno está de recuperação!");
  } else {
    print("Nota final: $nota, aluno está Aprovado!👍");
  }
}
