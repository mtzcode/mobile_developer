import 'carrinho_item.dart';
import 'package:flutter/material.dart';
import 'produto.dart';

enum StatusPedido {
  pendente,
  confirmado,
  emPreparacao,
  emEntrega,
  entregue,
  cancelado;

  String get statusText {
    switch (this) {
      case StatusPedido.pendente:
        return 'Pendente';
      case StatusPedido.confirmado:
        return 'Confirmado';
      case StatusPedido.emPreparacao:
        return 'Em Preparação';
      case StatusPedido.emEntrega:
        return 'Em Entrega';
      case StatusPedido.entregue:
        return 'Entregue';
      case StatusPedido.cancelado:
        return 'Cancelado';
    }
  }

  String get statusIcon {
    switch (this) {
      case StatusPedido.pendente:
        return '⏳';
      case StatusPedido.confirmado:
        return '✅';
      case StatusPedido.emPreparacao:
        return '👨‍🍳';
      case StatusPedido.emEntrega:
        return '🚚';
      case StatusPedido.entregue:
        return '📦';
      case StatusPedido.cancelado:
        return '❌';
    }
  }

  Color get statusColor {
    switch (this) {
      case StatusPedido.pendente:
        return Colors.orange;
      case StatusPedido.confirmado:
        return Colors.blue;
      case StatusPedido.emPreparacao:
        return Colors.purple;
      case StatusPedido.emEntrega:
        return Colors.indigo;
      case StatusPedido.entregue:
        return Colors.green;
      case StatusPedido.cancelado:
        return Colors.red;
    }
  }
}

class Pedido {
  final String id;
  final String usuarioId;
  final List<CarrinhoItem> itens;
  final double subtotal;
  final double taxaEntrega;
  final double total;
  final Map<String, dynamic>? enderecoEntrega;
  final String? observacoes;
  final StatusPedido status;
  final DateTime dataCriacao;
  final DateTime? dataConfirmacao;
  final DateTime? dataEntrega;
  final String? metodoPagamento;
  final String? codigoRastreamento;

  Pedido({
    required this.id,
    required this.usuarioId,
    required this.itens,
    required this.subtotal,
    required this.taxaEntrega,
    required this.total,
    this.enderecoEntrega,
    this.observacoes,
    this.status = StatusPedido.pendente,
    required this.dataCriacao,
    this.dataConfirmacao,
    this.dataEntrega,
    this.metodoPagamento,
    this.codigoRastreamento,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'itens': itens.map((item) => {
        'produto': item.produto.toMap(),
        'quantidade': item.quantidade,
      }).toList(),
      'subtotal': subtotal,
      'taxaEntrega': taxaEntrega,
      'total': total,
      'enderecoEntrega': enderecoEntrega,
      'observacoes': observacoes,
      'status': status.name,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataConfirmacao': dataConfirmacao?.toIso8601String(),
      'dataEntrega': dataEntrega?.toIso8601String(),
      'metodoPagamento': metodoPagamento,
      'codigoRastreamento': codigoRastreamento,
    };
  }

  // Criar a partir de Map (do Firestore)
  factory Pedido.fromMap(String id, Map<String, dynamic> map) {
    return Pedido(
      id: id,
      usuarioId: map['usuarioId'] ?? '',
      itens: (map['itens'] as List<dynamic>? ?? []).map((item) => CarrinhoItem(
        produto: Produto.fromMap(item['produto']),
        quantidade: item['quantidade'] ?? 1,
      )).toList(),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      taxaEntrega: (map['taxaEntrega'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      enderecoEntrega: map['enderecoEntrega'],
      observacoes: map['observacoes'],
      status: StatusPedido.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusPedido.pendente,
      ),
      dataCriacao: DateTime.parse(map['dataCriacao'] ?? DateTime.now().toIso8601String()),
      dataConfirmacao: map['dataConfirmacao'] != null 
          ? DateTime.parse(map['dataConfirmacao']) 
          : null,
      dataEntrega: map['dataEntrega'] != null 
          ? DateTime.parse(map['dataEntrega']) 
          : null,
      metodoPagamento: map['metodoPagamento'],
      codigoRastreamento: map['codigoRastreamento'],
    );
  }

  // Copiar com alterações
  Pedido copyWith({
    String? id,
    String? usuarioId,
    List<CarrinhoItem>? itens,
    double? subtotal,
    double? taxaEntrega,
    double? total,
    Map<String, dynamic>? enderecoEntrega,
    String? observacoes,
    StatusPedido? status,
    DateTime? dataCriacao,
    DateTime? dataConfirmacao,
    DateTime? dataEntrega,
    String? metodoPagamento,
    String? codigoRastreamento,
  }) {
    return Pedido(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      itens: itens ?? this.itens,
      subtotal: subtotal ?? this.subtotal,
      taxaEntrega: taxaEntrega ?? this.taxaEntrega,
      total: total ?? this.total,
      enderecoEntrega: enderecoEntrega ?? this.enderecoEntrega,
      observacoes: observacoes ?? this.observacoes,
      status: status ?? this.status,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataConfirmacao: dataConfirmacao ?? this.dataConfirmacao,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      metodoPagamento: metodoPagamento ?? this.metodoPagamento,
      codigoRastreamento: codigoRastreamento ?? this.codigoRastreamento,
    );
  }

  // Métodos auxiliares
  bool get podeCancelar => status == StatusPedido.pendente || status == StatusPedido.confirmado;
  bool get podeConfirmar => status == StatusPedido.pendente;
  bool get estaEmAndamento => status == StatusPedido.confirmado || status == StatusPedido.emPreparacao || status == StatusPedido.emEntrega;
  bool get foiEntregue => status == StatusPedido.entregue;
  bool get foiCancelado => status == StatusPedido.cancelado;

  String get statusText {
    switch (status) {
      case StatusPedido.pendente:
        return 'Pendente';
      case StatusPedido.confirmado:
        return 'Confirmado';
      case StatusPedido.emPreparacao:
        return 'Em Preparação';
      case StatusPedido.emEntrega:
        return 'Em Entrega';
      case StatusPedido.entregue:
        return 'Entregue';
      case StatusPedido.cancelado:
        return 'Cancelado';
    }
  }

  String get statusIcon {
    switch (status) {
      case StatusPedido.pendente:
        return '⏳';
      case StatusPedido.confirmado:
        return '✅';
      case StatusPedido.emPreparacao:
        return '👨‍🍳';
      case StatusPedido.emEntrega:
        return '🚚';
      case StatusPedido.entregue:
        return '📦';
      case StatusPedido.cancelado:
        return '❌';
    }
  }

  Color get statusColor {
    switch (status) {
      case StatusPedido.pendente:
        return Colors.orange;
      case StatusPedido.confirmado:
        return Colors.blue;
      case StatusPedido.emPreparacao:
        return Colors.purple;
      case StatusPedido.emEntrega:
        return Colors.indigo;
      case StatusPedido.entregue:
        return Colors.green;
      case StatusPedido.cancelado:
        return Colors.red;
    }
  }
}