// 7.Tente acessar o .length de uma variável String? texto = null; usando o operador !. O que acontece? Teste no console e explique o erro.

void main() {
String? cidade;
print(cidade!.length);
}
//erro na saida: Null check operator used on a null value, pois estou forcando acesso a uma variavel que é nula.