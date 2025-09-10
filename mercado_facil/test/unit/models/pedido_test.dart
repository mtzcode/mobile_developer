import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/data/models/pedido.dart';
import 'package:mercado_facil/data/models/produto.dart';
import 'package:mercado_facil/data/models/carrinho_item.dart';

void main() {
  group('Pedido Model Tests', () {
    late Pedido pedido;
    late List<CarrinhoItem> itens;
    late DateTime dataCriacao;

    setUp(() {
      dataCriacao = DateTime(2024, 1, 1, 12, 0, 0);
      
      final produto1 = Produto(
        id: 'prod_1',
        nome: 'Arroz',
        preco: 6.99,
        imagemUrl: 'https://example.com/arroz.jpg',
      );
      
      final produto2 = Produto(
        id: 'prod_2',
        nome: 'Feijão',
        preco: 7.49,
        imagemUrl: 'https://example.com/feijao.jpg',
      );

      itens = [
        CarrinhoItem(produto: produto1, quantidade: 2),
        CarrinhoItem(produto: produto2, quantidade: 1),
      ];

      pedido = Pedido(
        id: 'pedido_123',
        usuarioId: 'user_123',
        itens: itens,
        subtotal: 21.47,
        taxaEntrega: 5.00,
        total: 26.47,
        enderecoEntrega: {
          'rua': 'Rua das Flores',
          'numero': '123',
          'bairro': 'Centro',
          'cidade': 'São Paulo',
          'estado': 'SP',
          'cep': '01234567',
        },
        observacoes: 'Entregar na portaria',
        status: StatusPedido.pendente,
        dataCriacao: dataCriacao,
        metodoPagamento: 'Cartão de Crédito',
        codigoRastreamento: 'TRACK123456',
      );
    });

    group('Constructor', () {
      test('deve criar pedido com todos os campos obrigatórios', () {
        final pedido = Pedido(
          id: 'pedido_123',
          usuarioId: 'user_123',
          itens: itens,
          subtotal: 21.47,
          taxaEntrega: 5.00,
          total: 26.47,
          dataCriacao: dataCriacao,
        );

        expect(pedido.id, equals('pedido_123'));
        expect(pedido.usuarioId, equals('user_123'));
        expect(pedido.itens, equals(itens));
        expect(pedido.subtotal, equals(21.47));
        expect(pedido.taxaEntrega, equals(5.00));
        expect(pedido.total, equals(26.47));
        expect(pedido.dataCriacao, equals(dataCriacao));
        expect(pedido.enderecoEntrega, isNull);
        expect(pedido.observacoes, isNull);
        expect(pedido.status, equals(StatusPedido.pendente));
        expect(pedido.dataConfirmacao, isNull);
        expect(pedido.dataEntrega, isNull);
        expect(pedido.metodoPagamento, isNull);
        expect(pedido.codigoRastreamento, isNull);
      });

      test('deve criar pedido com todos os campos opcionais', () {
        final dataConfirmacao = DateTime(2024, 1, 1, 13, 0, 0);
        final dataEntrega = DateTime(2024, 1, 1, 15, 0, 0);

        final pedido = Pedido(
          id: 'pedido_123',
          usuarioId: 'user_123',
          itens: itens,
          subtotal: 21.47,
          taxaEntrega: 5.00,
          total: 26.47,
          enderecoEntrega: {'rua': 'Rua das Flores'},
          observacoes: 'Entregar na portaria',
          status: StatusPedido.confirmado,
          dataCriacao: dataCriacao,
          dataConfirmacao: dataConfirmacao,
          dataEntrega: dataEntrega,
          metodoPagamento: 'Cartão de Crédito',
          codigoRastreamento: 'TRACK123456',
        );

        expect(pedido.enderecoEntrega, equals({'rua': 'Rua das Flores'}));
        expect(pedido.observacoes, equals('Entregar na portaria'));
        expect(pedido.status, equals(StatusPedido.confirmado));
        expect(pedido.dataConfirmacao, equals(dataConfirmacao));
        expect(pedido.dataEntrega, equals(dataEntrega));
        expect(pedido.metodoPagamento, equals('Cartão de Crédito'));
        expect(pedido.codigoRastreamento, equals('TRACK123456'));
      });

      test('deve definir status como pendente por padrão', () {
        final pedido = Pedido(
          id: 'pedido_123',
          usuarioId: 'user_123',
          itens: itens,
          subtotal: 21.47,
          taxaEntrega: 5.00,
          total: 26.47,
          dataCriacao: dataCriacao,
        );

        expect(pedido.status, equals(StatusPedido.pendente));
      });
    });

    group('toMap', () {
      test('deve converter pedido para Map com todos os campos', () {
        final map = pedido.toMap();

        expect(map['usuarioId'], equals('user_123'));
        expect(map['itens'], isA<List>());
        expect(map['itens'].length, equals(2));
        expect(map['subtotal'], equals(21.47));
        expect(map['taxaEntrega'], equals(5.00));
        expect(map['total'], equals(26.47));
        expect(map['enderecoEntrega'], equals({
          'rua': 'Rua das Flores',
          'numero': '123',
          'bairro': 'Centro',
          'cidade': 'São Paulo',
          'estado': 'SP',
          'cep': '01234567',
        }));
        expect(map['observacoes'], equals('Entregar na portaria'));
        expect(map['status'], equals('pendente'));
        expect(map['dataCriacao'], equals(dataCriacao.toIso8601String()));
        expect(map['metodoPagamento'], equals('Cartão de Crédito'));
        expect(map['codigoRastreamento'], equals('TRACK123456'));
      });

      test('deve converter itens corretamente', () {
        final map = pedido.toMap();
        final itensMap = map['itens'] as List;

        expect(itensMap.length, equals(2));
        expect(itensMap[0]['produto']['id'], equals('prod_1'));
        expect(itensMap[0]['produto']['nome'], equals('Arroz'));
        expect(itensMap[0]['quantidade'], equals(2));
        expect(itensMap[1]['produto']['id'], equals('prod_2'));
        expect(itensMap[1]['produto']['nome'], equals('Feijão'));
        expect(itensMap[1]['quantidade'], equals(1));
      });

      test('deve converter pedido sem campos opcionais', () {
        final pedidoSimples = Pedido(
          id: 'pedido_123',
          usuarioId: 'user_123',
          itens: itens,
          subtotal: 21.47,
          taxaEntrega: 5.00,
          total: 26.47,
          dataCriacao: dataCriacao,
        );

        final map = pedidoSimples.toMap();

        expect(map['usuarioId'], equals('user_123'));
        expect(map['itens'], isA<List>());
        expect(map['subtotal'], equals(21.47));
        expect(map['taxaEntrega'], equals(5.00));
        expect(map['total'], equals(26.47));
        expect(map['status'], equals('pendente'));
        expect(map['dataCriacao'], equals(dataCriacao.toIso8601String()));
        expect(map['enderecoEntrega'], isNull);
        expect(map['observacoes'], isNull);
        expect(map['dataConfirmacao'], isNull);
        expect(map['dataEntrega'], isNull);
        expect(map['metodoPagamento'], isNull);
        expect(map['codigoRastreamento'], isNull);
      });
    });

    group('fromMap', () {
      test('deve criar pedido a partir de Map completo', () {
        final map = {
          'usuarioId': 'user_123',
          'itens': [
            {
              'produto': {
                'id': 'prod_1',
                'nome': 'Arroz',
                'preco': 6.99,
                'imagemUrl': 'https://example.com/arroz.jpg',
              },
              'quantidade': 2,
            },
            {
              'produto': {
                'id': 'prod_2',
                'nome': 'Feijão',
                'preco': 7.49,
                'imagemUrl': 'https://example.com/feijao.jpg',
              },
              'quantidade': 1,
            },
          ],
          'subtotal': 21.47,
          'taxaEntrega': 5.00,
          'total': 26.47,
          'enderecoEntrega': {
            'rua': 'Rua das Flores',
            'numero': '123',
          },
          'observacoes': 'Entregar na portaria',
          'status': 'confirmado',
          'dataCriacao': dataCriacao.toIso8601String(),
          'dataConfirmacao': DateTime(2024, 1, 1, 13, 0, 0).toIso8601String(),
          'dataEntrega': DateTime(2024, 1, 1, 15, 0, 0).toIso8601String(),
          'metodoPagamento': 'Cartão de Crédito',
          'codigoRastreamento': 'TRACK123456',
        };

        final pedido = Pedido.fromMap('pedido_123', map);

        expect(pedido.id, equals('pedido_123'));
        expect(pedido.usuarioId, equals('user_123'));
        expect(pedido.itens.length, equals(2));
        expect(pedido.subtotal, equals(21.47));
        expect(pedido.taxaEntrega, equals(5.00));
        expect(pedido.total, equals(26.47));
        expect(pedido.enderecoEntrega, equals({
          'rua': 'Rua das Flores',
          'numero': '123',
        }));
        expect(pedido.observacoes, equals('Entregar na portaria'));
        expect(pedido.status, equals(StatusPedido.confirmado));
        expect(pedido.dataCriacao, equals(dataCriacao));
        expect(pedido.metodoPagamento, equals('Cartão de Crédito'));
        expect(pedido.codigoRastreamento, equals('TRACK123456'));
      });

      test('deve criar pedido a partir de Map com campos ausentes', () {
        final map = {
          'usuarioId': 'user_123',
          'itens': [],
          'subtotal': 21.47,
          'taxaEntrega': 5.00,
          'total': 26.47,
        };

        final pedido = Pedido.fromMap('pedido_123', map);

        expect(pedido.id, equals('pedido_123'));
        expect(pedido.usuarioId, equals('user_123'));
        expect(pedido.itens, isEmpty);
        expect(pedido.subtotal, equals(21.47));
        expect(pedido.taxaEntrega, equals(5.00));
        expect(pedido.total, equals(26.47));
        expect(pedido.enderecoEntrega, isNull);
        expect(pedido.observacoes, isNull);
        expect(pedido.status, equals(StatusPedido.pendente));
        expect(pedido.dataConfirmacao, isNull);
        expect(pedido.dataEntrega, isNull);
        expect(pedido.metodoPagamento, isNull);
        expect(pedido.codigoRastreamento, isNull);
      });

      test('deve lidar com valores nulos no Map', () {
        final map = {
          'usuarioId': 'user_123',
          'itens': [],
          'subtotal': 21.47,
          'taxaEntrega': 5.00,
          'total': 26.47,
          'enderecoEntrega': null,
          'observacoes': null,
          'dataConfirmacao': null,
          'dataEntrega': null,
          'metodoPagamento': null,
          'codigoRastreamento': null,
        };

        final pedido = Pedido.fromMap('pedido_123', map);

        expect(pedido.enderecoEntrega, isNull);
        expect(pedido.observacoes, isNull);
        expect(pedido.dataConfirmacao, isNull);
        expect(pedido.dataEntrega, isNull);
        expect(pedido.metodoPagamento, isNull);
        expect(pedido.codigoRastreamento, isNull);
      });

      test('deve usar valores padrão para campos ausentes', () {
        final map = <String, dynamic>{};

        final pedido = Pedido.fromMap('pedido_123', map);

        expect(pedido.id, equals('pedido_123'));
        expect(pedido.usuarioId, equals(''));
        expect(pedido.itens, isEmpty);
        expect(pedido.subtotal, equals(0.0));
        expect(pedido.taxaEntrega, equals(0.0));
        expect(pedido.total, equals(0.0));
        expect(pedido.enderecoEntrega, isNull);
        expect(pedido.observacoes, isNull);
        expect(pedido.status, equals(StatusPedido.pendente));
        expect(pedido.dataConfirmacao, isNull);
        expect(pedido.dataEntrega, isNull);
        expect(pedido.metodoPagamento, isNull);
        expect(pedido.codigoRastreamento, isNull);
      });
    });

    group('copyWith', () {
      test('deve criar cópia idêntica quando nenhum parâmetro é fornecido', () {
        final copia = pedido.copyWith();

        expect(copia.id, equals(pedido.id));
        expect(copia.usuarioId, equals(pedido.usuarioId));
        expect(copia.itens, equals(pedido.itens));
        expect(copia.subtotal, equals(pedido.subtotal));
        expect(copia.taxaEntrega, equals(pedido.taxaEntrega));
        expect(copia.total, equals(pedido.total));
        expect(copia.enderecoEntrega, equals(pedido.enderecoEntrega));
        expect(copia.observacoes, equals(pedido.observacoes));
        expect(copia.status, equals(pedido.status));
        expect(copia.dataCriacao, equals(pedido.dataCriacao));
        expect(copia.dataConfirmacao, equals(pedido.dataConfirmacao));
        expect(copia.dataEntrega, equals(pedido.dataEntrega));
        expect(copia.metodoPagamento, equals(pedido.metodoPagamento));
        expect(copia.codigoRastreamento, equals(pedido.codigoRastreamento));
      });

      test('deve modificar apenas os campos especificados', () {
        final copia = pedido.copyWith(
          status: StatusPedido.confirmado,
          observacoes: 'Novas observações',
          total: 30.00,
        );

        expect(copia.id, equals(pedido.id));
        expect(copia.usuarioId, equals(pedido.usuarioId));
        expect(copia.itens, equals(pedido.itens));
        expect(copia.subtotal, equals(pedido.subtotal));
        expect(copia.taxaEntrega, equals(pedido.taxaEntrega));
        expect(copia.total, equals(30.00));
        expect(copia.enderecoEntrega, equals(pedido.enderecoEntrega));
        expect(copia.observacoes, equals('Novas observações'));
        expect(copia.status, equals(StatusPedido.confirmado));
        expect(copia.dataCriacao, equals(pedido.dataCriacao));
        expect(copia.dataConfirmacao, equals(pedido.dataConfirmacao));
        expect(copia.dataEntrega, equals(pedido.dataEntrega));
        expect(copia.metodoPagamento, equals(pedido.metodoPagamento));
        expect(copia.codigoRastreamento, equals(pedido.codigoRastreamento));
      });
    });

    group('StatusPedido Enum', () {
      test('deve ter todos os valores esperados', () {
        expect(StatusPedido.values.length, equals(6));
        expect(StatusPedido.values, contains(StatusPedido.pendente));
        expect(StatusPedido.values, contains(StatusPedido.confirmado));
        expect(StatusPedido.values, contains(StatusPedido.emPreparacao));
        expect(StatusPedido.values, contains(StatusPedido.emEntrega));
        expect(StatusPedido.values, contains(StatusPedido.entregue));
        expect(StatusPedido.values, contains(StatusPedido.cancelado));
      });
    });

    group('Métodos auxiliares', () {
      test('podeCancelar deve retornar true para status pendente', () {
        final pedidoPendente = pedido.copyWith(status: StatusPedido.pendente);
        expect(pedidoPendente.podeCancelar, isTrue);
      });

      test('podeCancelar deve retornar true para status confirmado', () {
        final pedidoConfirmado = pedido.copyWith(status: StatusPedido.confirmado);
        expect(pedidoConfirmado.podeCancelar, isTrue);
      });

      test('podeCancelar deve retornar false para outros status', () {
        final pedidoEmPreparacao = pedido.copyWith(status: StatusPedido.emPreparacao);
        expect(pedidoEmPreparacao.podeCancelar, isFalse);

        final pedidoEntregue = pedido.copyWith(status: StatusPedido.entregue);
        expect(pedidoEntregue.podeCancelar, isFalse);

        final pedidoCancelado = pedido.copyWith(status: StatusPedido.cancelado);
        expect(pedidoCancelado.podeCancelar, isFalse);
      });

      test('podeConfirmar deve retornar true apenas para status pendente', () {
        final pedidoPendente = pedido.copyWith(status: StatusPedido.pendente);
        expect(pedidoPendente.podeConfirmar, isTrue);

        final pedidoConfirmado = pedido.copyWith(status: StatusPedido.confirmado);
        expect(pedidoConfirmado.podeConfirmar, isFalse);
      });

      test('estaEmAndamento deve retornar true para status em andamento', () {
        final pedidoConfirmado = pedido.copyWith(status: StatusPedido.confirmado);
        expect(pedidoConfirmado.estaEmAndamento, isTrue);

        final pedidoEmPreparacao = pedido.copyWith(status: StatusPedido.emPreparacao);
        expect(pedidoEmPreparacao.estaEmAndamento, isTrue);

        final pedidoEmEntrega = pedido.copyWith(status: StatusPedido.emEntrega);
        expect(pedidoEmEntrega.estaEmAndamento, isTrue);
      });

      test('estaEmAndamento deve retornar false para outros status', () {
        final pedidoPendente = pedido.copyWith(status: StatusPedido.pendente);
        expect(pedidoPendente.estaEmAndamento, isFalse);

        final pedidoEntregue = pedido.copyWith(status: StatusPedido.entregue);
        expect(pedidoEntregue.estaEmAndamento, isFalse);

        final pedidoCancelado = pedido.copyWith(status: StatusPedido.cancelado);
        expect(pedidoCancelado.estaEmAndamento, isFalse);
      });

      test('foiEntregue deve retornar true apenas para status entregue', () {
        final pedidoEntregue = pedido.copyWith(status: StatusPedido.entregue);
        expect(pedidoEntregue.foiEntregue, isTrue);

        final pedidoPendente = pedido.copyWith(status: StatusPedido.pendente);
        expect(pedidoPendente.foiEntregue, isFalse);
      });

      test('foiCancelado deve retornar true apenas para status cancelado', () {
        final pedidoCancelado = pedido.copyWith(status: StatusPedido.cancelado);
        expect(pedidoCancelado.foiCancelado, isTrue);

        final pedidoPendente = pedido.copyWith(status: StatusPedido.pendente);
        expect(pedidoPendente.foiCancelado, isFalse);
      });
    });

    group('Status Text, Icon e Color', () {
      test('statusText deve retornar texto correto para cada status', () {
        expect(StatusPedido.pendente.statusText, equals('Pendente'));
        expect(StatusPedido.confirmado.statusText, equals('Confirmado'));
        expect(StatusPedido.emPreparacao.statusText, equals('Em Preparação'));
        expect(StatusPedido.emEntrega.statusText, equals('Em Entrega'));
        expect(StatusPedido.entregue.statusText, equals('Entregue'));
        expect(StatusPedido.cancelado.statusText, equals('Cancelado'));
      });

      test('statusIcon deve retornar ícone correto para cada status', () {
        expect(StatusPedido.pendente.statusIcon, equals('⏳'));
        expect(StatusPedido.confirmado.statusIcon, equals('✅'));
        expect(StatusPedido.emPreparacao.statusIcon, equals('👨‍🍳'));
        expect(StatusPedido.emEntrega.statusIcon, equals('🚚'));
        expect(StatusPedido.entregue.statusIcon, equals('📦'));
        expect(StatusPedido.cancelado.statusIcon, equals('❌'));
      });

      test('statusColor deve retornar cor correta para cada status', () {
        expect(StatusPedido.pendente.statusColor, equals(Colors.orange));
        expect(StatusPedido.confirmado.statusColor, equals(Colors.blue));
        expect(StatusPedido.emPreparacao.statusColor, equals(Colors.purple));
        expect(StatusPedido.emEntrega.statusColor, equals(Colors.indigo));
        expect(StatusPedido.entregue.statusColor, equals(Colors.green));
        expect(StatusPedido.cancelado.statusColor, equals(Colors.red));
      });
    });
  });
} 