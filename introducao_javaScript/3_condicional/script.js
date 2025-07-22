// // 1. Verificar se o número é positivo, negativo ou zero
// Peça um número ao usuário com prompt()
// Mostre se ele é positivo, negativo ou igual a zero

let num1 = Number(prompt("Digite um número: "));

if (num1 > 0) {
    console.log(`${num1} é um número positivo`)
} else if (num1 < 0) {
    console.log(`${num1} é um número negativo`)
} else {
    console.log ("O número digitado foi zero")
}

// // 2. Aprovado ou reprovado
// Peça uma nota final (0 a 10)
// Se for maior ou igual a 7 → "Aprovado"
// Senão → "Reprovado"

let nota1 = Number(prompt("Digite a nota final do aluno: "))

if (nota1 >= 7) {
    console.log("Aluno aprovado!")
} else {
    console.log("Aluno reprovado!")
}

// // 3. Categoria por idade
// Peça a idade de uma pessoa
// Se for menor que 12 → "Criança"
// Se for entre 12 e 17 → "Adolescente"
// Se for 18 ou mais → "Adulto"

let idade1 = Number(prompt("Informe a idade do usuário: "));

if (idade1 >= 18) {
  console.log(`Idade: ${idade1} anos\nCategoria: Adulto`);
} else if (idade1 >= 12 && idade1 <= 17) {
  console.log(`Idade: ${idade1} anos\nCategoria: Adolescente`);
} else {
  console.log(`Idade: ${idade1} anos\nCategoria: Criança`);
}

// 4. Verificar par ou ímpar
// Peça um número
// Diga se ele é par ou ímpar

let num2 = Number(prompt("Digite um número: "));

if (num2 % 2 == 0) {
  console.log(`O número ${num2} é par`);
} else {
  console.log(`O número ${num2} é impar`);
}

// 5. Desconto por forma de pagamento
// Peça o valor da compra e a forma de pagamento
// Se for "pix" → 10% de desconto
// Se for "crédito" → sem desconto
// Se for "débito" → 5% de desconto
// Mostre o valor final

let vlcompra = Number(prompt("Digite o valor da compra: R$ "));
let fpagamento = prompt("Digite a forma de pgto (Pix, Crédito ou Débito: ");
let total;

if (fpagamento === "Pix") {
  total = vlcompra * 0.9;
  console.log(`O valor total da compra é de : R$ ${total.toFixed(2)}`);
} else if (fpagamento === "Débito") {
  total = vlcompra * 0.95;
  console.log(`O valor total da compra é de : R$ ${total.toFixed(2)}`);
} else if (fpagamento === "Crédito") {
  total = vlcompra;
  console.log(`O valor total da compra é de : R$ ${total.toFixed(2)}`);
} else {
  console.log("Forma de pagamento inválida!");
}

// 6. Calculadora simples
// Peça dois números e uma operação (+, -, *, /)
// Use if/else para realizar a operação escolhida
// Mostre o resultado final

let num3 = Number(prompt("Digite o primeiro número: "));
let num4 = Number(prompt("Digite o segundo número: "));
let operacao = prompt("Escolha uma operação (+, -, * ou /)");
let resultado;

if (operacao === "+") {
  resultado = num3 + num4;
  console.log(`${num3} + ${num4} = ${resultado}`);
} else if (operacao === "-") {
  resultado = num3 - num4;
  console.log(`${num3} - ${num4} = ${resultado}`);
} else if (operacao === "*") {
  resultado = num3 * num4;
  console.log(`${num3} * ${num4} = ${resultado}`);
} else if (operacao === "/") {
  resultado = num3 / num4;
  console.log(`${num3} / ${num4} = ${resultado}`);
} else {
  console.log("Operação inválida, escolha novamente!");
}

// 7. Maior de três números
// Peça 3 números diferentes
// Mostre qual deles é o maior

let num5 = Number(prompt("Digite o primeiro número: "));
let num6 = Number(prompt("Digite o segundo número: "));
let num7 = Number(prompt("Digite o terceiro número: "));

if (num5 > num6 && num5 > num7) {
  console.log(`Entre os números digitados, o ${num5} é o maior`);
} else if (num6 > num7) {
  console.log(`Entre os números digitados, o ${num6} é o maior`);
} else {
  console.log(`Entre os números digitados, o ${num7} é o maior`);
}

// 8. Classificação de nota com conceito
// Peça a nota de 0 a 10
// Se for >= 9 → "Conceito A"
// Se for >= 7 → "Conceito B"
// Se for >= 5 → "Conceito C"
// Senão → "Conceito D"

let nota2 = Number(prompt("Digite a nota do aluno (De 0 a 10): "));

if (nota2 >= 9) {
  console.log(`Nota final: ${nota2} | Conceito A`);
} else if (nota2 >= 7) {
  console.log(`Nota final: ${nota2} | Conceito B`);
} else if (nota2 >= 5) {
  console.log(`Nota final: ${nota2} | Conceito C`);
} else {
  console.log(`Nota final: ${nota2} | Conceito D`);
}

// 9. Verificar se pode votar
// Peça a idade
// Se for menor de 16 → "Não pode votar"
// Se for entre 16 e 17 ou maior que 70 → "Voto facultativo"
// Se for entre 18 e 70 → "Voto obrigatório"

let idade = Number(prompt("Digite sua idade: "));

if (idade < 16) {
  console.log("Não pode votar");
} else if ((idade >= 16 && idade <= 17) || idade > 70) {
  console.log("Voto facultativo");
} else if (idade >= 18 && idade <= 70) {
  console.log("Voto obrigatório");
} else {
  console.log("Idade Inválida");
}

// 10. Simulador de temperatura
// Peça a temperatura atual (número)
// Se for menor que 15 → "Muito frio"
// Se for entre 15 e 25 → "Clima agradável"
// Se for maior que 25 → "Está quente"

let temperatura = Number(prompt("Qual a temperatura atual: "));

if (temperatura < 15) {
  console.log("Muito frio");
} else if ((temperatura >= 15 && temperatura <= 25) {
  console.log("Clima agradável");
} else if (temperatura >= 25) {
  console.log("Está quente");
} else {
  console.log("temperatura Inválida");
}
