// Crie uma simulação de ponto eletrônico:
// Mostre a hora de entrada com DateTime.now()
// Se a entrada for antes de 8h → “Ponto registrado: dentro do horário”
// Se for depois → “Atraso no ponto! Entrada registrada”

void main() {
  var horaEntrada = DateTime.now();
  print(
    "Hora da entrada: ${horaEntrada.hour}:${horaEntrada.minute}:${horaEntrada.second}");
  if (horaEntrada.hour < 8) {
    print("Ponto registrado: dentro do horário");
  } else {
    print("Atraso no ponto!\nEntrada registrada");
  }
}
