//Exercicios da função Prompt

// 1. Peça o nome do usuário e mostre uma mensagem
let nome1 = prompt("Digite seu nome: ");
console.log(`Olá, ${nome1}! Seja bem-vindo ao nosso site.`);

// 2. Peça dois números e exiba a soma

let num1 = prompt("Digite o primeiro número: ");
let num2 = prompt("Digite o segundo número: ");

num1 = Number(num1);
num2 = Number(num2);

let soma = num1 + num2;

// console.log(`A soma de ${num1} e ${num2} é ${soma}.`);

// 3. Peça a idade e diga se a pessoa é maior de idade

let idade1 = prompt("Digite a sua idade: ");
idade1 = Number(idade);

if (idade1 >= 18) {
  console.log("Você é maior de idade.");
} else {
  console.log("Você é menor de idade.");
}

// // 4. Peça o nome e o ano de nascimento, e calcule a idade

let nome = prompt("Digite seu nome: ");
let anoNascimento = prompt("Digite o ano de nascimento: ");
let anoAtual = 2025;
let idade = anoAtual - anoNascimento;

console.log(`${nome}, você tem ${idade} anos.`);

// 5. Peça dois números e mostre qual é o maior

let num3 = prompt("Digite o primeiro número: ");
let num4 = prompt("Digite o segundo número: ");

num3 = Number(num3);
num4 = Number(num4);

if (num3 > num4) {
  console.log(`O número ${num3} é maior que o número ${num4}.`);
} else {
  console.log(`O número ${num4} é maior que o número ${num3}.`);
}

// 6. Peça a nota de um aluno e informe se foi aprovado (média >= 7)

let num5 = prompt("Digite a primeira nota: ");
let num6 = prompt("Digite a segunda nota: ");
let num7 = prompt("Digite a terceira nota: ");
let num8 = prompt("e por fim a quarta nota: ");
media = (num5 + num6 + num7 + num8) / 4;
num5, num6, num7, num8, media = Number(num5, num6, num7, num8, media);

if (media >= 7) {
  console.log(`Aluno aprovado, Nota final: ${media}`);
} else {
  console.log(`Aluno reprovado, Nota final: ${media}:`);
}

// 7. Peça um número e mostre se é par ou ímpar

let num = prompt("Digite um número: ");
num = Number(num);

if (num % 2 == 0) {
  console.log(`O número ${num} é par`);
} else {
  console.log(`O número ${num} é impar`);
}

// 8.Peça dois valores e mostre a multiplicação, divisão, soma e subtração
// Entrada: número 1 e número 2
// Saída: resultados das 4 operações

let num9 = prompt("Digite o primeiro número: ");
let num10 = prompt("Digite o segundo número: ");
num1 = Number(num9);
num2 = Number(num10);

console.log(`O resultado entre ${num9} + ${num10} é: `, num9 + num10);
console.log(`A diferença entre ${num9} - ${num10} é: `, num9 - num10);
console.log(`O produto entre ${num9} * ${num10} é: `, num9 * num10);
console.log(`O quociente entre ${num9} / ${num10} é: `, num1 / num10);

// 9. Peça a distância em km e o tempo em horas, calcule a velocidade média
// Entrada: distância e tempo
// Saída: "A velocidade média foi de X km/h"

let distancia = prompt("Informe a distancia percorrida em km: ");
let tempo = prompt("Informe o tempo percorrido em horas: ");
let resultado = distancia / tempo;
distancia = Number(distancia);
tempo = Number(tempo);
resultado = Number(resultado);

console.log(`A velocidade média foi de ${resultado} km/h`);

// 10. Peça um valor em reais e mostre quanto daria em dólar (cotação fixa)
// Entrada: valor em reais
// Saída: "R$100 equivalem a $20" (exemplo com cotação R$5.00)

let vlReal = prompt("Informe o valor que deseja converter em R$(Real-BR): ");
const cotacaoDolar = 5.65;
let conversao = vlReal / cotacaoDolar;
vlReal = Number(vlReal);

console.log(`Conversao de R$ para U$: ${conversao.toFixed(2)}`);
