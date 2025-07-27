// 12.Etiqueta de produto
// Em um supermercado, cada produto tem um nome fixo e uma data de validade que só será conhecida depois que o produto for registrado no sistema.

// Objetivo:
// Crie um const com o nome do produto: "Leite Integral"
// Crie um final com a validade usando: DateTime.parse("2025-12-01")

late final int?
idProduto; //a intenção aqui é o idProduto seja aplicado quando o produto for criado e ai o codigo sera aplicado e nao pode ser alterado, esta correto essa aplicacao?
late final int? codigoBarras; //Segue a mesma logica do idProduto
final dataValidade = DateTime.parse("2025-12-01");
void main() {
  idProduto = 123;
  codigoBarras = 78912345678;
  const nomeProduto = "Leite Integral";

  print("======| Supermercado XYZ |====== ");
  print("");
  print("--------------------------------");
  print("ID ${idProduto ?? "Código não cadastrado"}");
  print(nomeProduto);
  print("Codigo de Barras: ${codigoBarras ?? "Código não cadastrado"}");
  print("Válidade:${dataValidade.day}/${dataValidade.month}/${dataValidade.year}");
  print("--------------------------------");
}
