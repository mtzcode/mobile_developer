import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/endereco.dart';

class EnderecoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'enderecos';
  
  // Buscar endereço por CEP (com cache)
  Future<Endereco?> buscarEnderecoPorCep(String cep) async {
    try {
      // Limpar CEP (remover caracteres especiais)
      final cepLimpo = cep.replaceAll(RegExp(r'[^\d]'), '');
      
      // 1. Primeiro, tentar buscar no cache (Firestore)
      final cacheResult = await _buscarNoCache(cepLimpo);
      
      if (cacheResult != null) {
        await _incrementarContadorUso(cacheResult.id);
        return cacheResult;
      }
      
      // 2. Se não encontrou no cache, buscar na API
      final apiResult = await _buscarNaApi(cepLimpo);
      
      if (apiResult != null) {
        await _salvarNoCache(apiResult);
        return apiResult;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Buscar no cache (Firestore)
  Future<Endereco?> _buscarNoCache(String cep) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('cep', isEqualTo: cep)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return Endereco.fromMap(doc.id, doc.data());
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Buscar na API ViaCEP
  Future<Endereco?> _buscarNaApi(String cep) async {
    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Verificar se há erro na resposta
        if (data['erro'] == true) {
          return null;
        }
        
        // Criar objeto Endereco a partir dos dados da API
        final endereco = Endereco.fromViaCep(data, cep);
        return endereco;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Salvar no cache (Firestore)
  Future<void> _salvarNoCache(Endereco endereco) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final enderecoComId = endereco.copyWith(id: docRef.id);
      
      await docRef.set(enderecoComId.toMap());
    } catch (e) {
      // Ignorar erro ao salvar no cache
    }
  }

  // Incrementar contador de uso
  Future<void> _incrementarContadorUso(String enderecoId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(enderecoId)
          .update({'contadorUso': FieldValue.increment(1)});
    } catch (e) {
      // Ignorar erro ao incrementar contador
    }
  }

  // Buscar endereços mais usados (para sugestões)
  Future<List<Endereco>> getEnderecosPopulares({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .orderBy('contadorUso', descending: true)
          .limit(limit)
          .get();
      
      return query.docs.map((doc) {
        return Endereco.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Buscar endereços por cidade
  Future<List<Endereco>> buscarPorCidade(String cidade) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('cidade', isGreaterThanOrEqualTo: cidade)
          .where('cidade', isLessThan: '$cidade\uf8ff')
          .limit(20)
          .get();
      
      return query.docs.map((doc) {
        return Endereco.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Estatísticas do cache
  Future<Map<String, dynamic>> getEstatisticas() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final totalEnderecos = snapshot.docs.length;
      
      int totalUsos = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final contador = data['contadorUso'];
        if (contador != null) {
          totalUsos += contador is int ? contador : (contador as num).toInt();
        }
      }
      
      return {
        'totalEnderecos': totalEnderecos,
        'totalUsos': totalUsos,
        'mediaUsos': totalEnderecos > 0 ? totalUsos / totalEnderecos : 0,
      };
    } catch (e) {
      return {};
    }
  }

  // Limpar cache antigo (endereços não usados há muito tempo)
  Future<void> limparCacheAntigo({int dias = 30}) async {
    try {
      final dataLimite = DateTime.now().subtract(Duration(days: dias));
      
      final query = await _firestore
          .collection(_collection)
          .where('dataCadastro', isLessThan: dataLimite.toIso8601String())
          .where('contadorUso', isLessThan: 2)
          .get();
      
      for (final doc in query.docs) {
        await doc.reference.delete();
      }
      
      // Cache antigo limpo
    } catch (e) {
      // Ignorar erro ao limpar cache
    }
  }
}