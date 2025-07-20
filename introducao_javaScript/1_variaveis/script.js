/*Exercício 1 – Criando e exibindo variáveis
Crie três variáveis:
- nome com seu nome
- idade com sua idade
- cidade com a cidade onde mora
Depois, exiba uma frase usando essas variáveis*/

let nome = "Pabllo";
let idade = 32;
let cidade = "Ribeirão Preto";

console.log(`Olá, meu nome é ${nome}, tenho ${idade} anos e atualmente moro em ${cidade}-São Paulo.`)

/*Exercício 2 – Somando dois números
Crie duas variáveis numéricas chamadas num1 e num2.
Depois, crie uma terceira variável chamada soma que guarda o resultado da soma entre os dois números.
Exiba o resultado no console.*/

let num1 = 10;
let num2 = 15;
let soma = num1 + num2;

console.log(`A soma dos valores ${num1} + ${num2} é igual a ${soma}`)

/*Exercício 3 – Alterando valores com let
Crie uma variável contador com valor inicial 0.
Depois, aumente esse valor duas vezes (ex: +1 e +1 novamente).
Exiba o valor final no console.*/

let contador = 0;
contador = contador + 1;
contador = contador + 1;

console.log(contador)
//Saida foi igual a 2

/*Exercício 4 – Usando const corretamente
Crie uma constante chamada pi com o valor 3.14.
Depois tente multiplicar esse valor por um número para calcular a área de um círculo com raio 5.*/

// Dica: área = pi * raio * raio

const pi = 3.14;
let raio = 5;
let area = pi * raio * raio

console.log(`O tamanho da área do circule é: ${area}`)
//Se eu tentar mudar o valor de pi da erro

/*Exercício 5 – Template String
Crie as variáveis `produto`, `preco`, e `quantidade`.
Depois, exiba uma frase como:
Você comprou 3 unidades de Caneta por R$ 2.50 cada.*/

let produto = "Caneta";
let quantidade = 3
let preco = 2.50

console.log(`Voce comprou ${quantidade} unidades de ${produto} por R$ ${preco.toFixed(2)} cada`)

/*Exercício 6 – Calculando troco
Crie uma variável `valorPago = 100` e outra `valorCompra = 76.50`.
Crie uma variável `troco` que armazena a diferença entre os dois valores.
Mostre a mensagem:
Seu troco será de R$ 23.50*/

let valorPago = 100
let valorCompra = 76.50
let troco = valorPago - valorCompra

console.log(`Seu troco será de R$ ${troco.toFixed(2)}`)

/*Exercício 7 – Usando variáveis booleanas**
Crie uma variável `temCarteira = true` e `idade = 17`.
Depois, exiba no console:
Se a pessoa tiver 18 anos ou mais e tiver carteira, escreva: "Pode dirigir"
Se não, escreva: "Não pode dirigir"*/

let temCarteira = true;
let idade2 = 17;

if (idade2 >= 18 && temCarteira === true) {
  console.log("Pode dirigir");
} else {
  console.log("Não pode dirigir");
}