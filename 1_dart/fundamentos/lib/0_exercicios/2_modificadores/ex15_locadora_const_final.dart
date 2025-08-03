// 15.Aluguel de carro
// Um sistema de aluguel de carros define o nome da empresa como constante e gera a data de retirada com DateTime.now().

// Objetivo:
// Crie:
// const empresa = "Locadora Rápida"
// final dataRetirada = DateTime.now();

void main() {
  const empresa = "Locadora Rápida";
  final dataRetirada = DateTime.now();

  print("======| $empresa |====== ");
  print(
    "Data de retirada de veículo: ${dataRetirada.day}/${dataRetirada.month}/${dataRetirada.year}",
  );
}
