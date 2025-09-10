import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class FirestoreAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'usuarios';
  
  // Chave para armazenar sessão local
  static const String _sessionKey = 'user_session';

  // Criptografar senha
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Registrar novo usuário
  Future<Usuario> registrarUsuario({
    required String nome,
    required String email,
    required String whatsapp,
    required String senha,
  }) async {
    try {
      // Verificar se email já existe
      final emailQuery = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      
      if (emailQuery.docs.isNotEmpty) {
        throw Exception('Este email já está cadastrado');
      }

      // Criar documento com ID único
      final docRef = _firestore.collection(_collection).doc();
      
      // Criar usuário
      final usuario = Usuario(
        id: docRef.id,
        nome: nome,
        email: email.toLowerCase(),
        whatsapp: whatsapp,
        senhaHash: _hashPassword(senha),
        dataCadastro: DateTime.now(),
        cadastroCompleto: false,
      );

      // Salvar no Firestore
      await docRef.set(usuario.toMap());
      
      return usuario;
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }

  // Fazer login
  Future<Usuario> fazerLogin(String email, String senha) async {
    try {
      // Buscar usuário por email
      final query = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email.toLowerCase())
          .where('ativo', isEqualTo: true)
          .get();
      
      if (query.docs.isEmpty) {
        throw Exception('Email ou senha incorretos');
      }

      final doc = query.docs.first;
      final usuario = Usuario.fromMap(doc.id, doc.data());
      
      // Verificar senha
      if (usuario.senhaHash != _hashPassword(senha)) {
        throw Exception('Email ou senha incorretos');
      }

      // Salvar sessão local
      await _salvarSessao(usuario);
      
      return usuario;
    } catch (e) {
      throw Exception('Erro no login: $e');
    }
  }

  // Verificar se está logado
  Future<Usuario?> getUsuarioLogado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString(_sessionKey);
      
      if (sessionData == null) return null;
      
      final session = json.decode(sessionData);
      final userId = session['userId'];
      
      // Buscar usuário no Firestore
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) return null;
      
      final usuario = Usuario.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      
      if (!usuario.ativo) return null;
      
      return usuario;
    } catch (e) {
      return null;
    }
  }

  // Fazer logout
  Future<void> fazerLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      // Ignorar erro no logout
    }
  }

  // Salvar sessão local
  Future<void> _salvarSessao(Usuario usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = {
        'userId': usuario.id,
        'email': usuario.email,
        'nome': usuario.nome,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_sessionKey, json.encode(sessionData));
    } catch (e) {
      // Ignorar erro ao salvar sessão
    }
  }

  // Atualizar dados do usuário
  Future<void> atualizarUsuario(String userId, Map<String, dynamic> dados) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(dados);
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  // Buscar usuário por ID
  Future<Usuario?> getUsuarioPorId(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) return null;
      
      return Usuario.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Enviar email de recuperação (simulado)
  Future<void> enviarEmailRecuperacao(String email) async {
    try {
      // Verificar se email existe
      final query = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      
      if (query.docs.isEmpty) {
        throw Exception('Email não encontrado');
      }

      // Em um app real, aqui enviaria o email
    } catch (e) {
      throw Exception('Erro ao enviar email de recuperação: $e');
    }
  }
} 