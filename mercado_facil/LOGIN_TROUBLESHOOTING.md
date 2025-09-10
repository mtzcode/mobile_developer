# Solução de Problemas de Login

## Problema: Não consigo fazer login

### Diagnóstico

O app está funcionando corretamente - o Firebase foi inicializado e o AuthWrapper está redirecionando para a tela de login. O problema pode ser:

1. **Não há usuários cadastrados no Firestore**
2. **Credenciais incorretas**
3. **Problema na validação de senha**

### Soluções

#### 1. Usar Credenciais de Teste Automáticas

O sistema agora cria automaticamente um usuário de teste se você usar as credenciais:

- **Email:** `teste@teste.com`
- **Senha:** `123456`

#### 2. Criar Usuário Manualmente

Execute o script para criar um usuário de teste:

```bash
cd mercado_facil
dart run lib/scripts/create_test_user.dart
```

#### 3. Verificar Logs

Os logs agora mostram informações detalhadas sobre o processo de login:

- `🔍 [LOGIN]` - Busca de usuário
- `📊 [LOGIN]` - Quantidade de documentos encontrados
- `✅ [LOGIN]` - Sucessos
- `❌ [LOGIN]` - Erros

#### 4. Verificar Firestore

1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Vá para o projeto do Mercado Fácil
3. Acesse Firestore Database
4. Verifique se existe a coleção `usuarios`
5. Verifique se há documentos na coleção

#### 5. Estrutura Esperada do Documento

Cada usuário deve ter a seguinte estrutura:

```json
{
  "nome": "Nome do Usuário",
  "email": "email@exemplo.com",
  "whatsapp": "11999999999",
  "senhaHash": "hash_da_senha_criptografada",
  "dataCadastro": "2024-01-01T00:00:00.000Z",
  "ativo": true,
  "cadastroCompleto": true
}
```

### Teste Rápido

1. **Reinicie o app**
2. **Use as credenciais de teste:**
   - Email: `teste@teste.com`
   - Senha: `123456`
3. **Verifique os logs no console**

### Se Ainda Não Funcionar

1. **Verifique a conexão com a internet**
2. **Verifique se o Firebase está configurado corretamente**
3. **Verifique se as regras do Firestore permitem leitura/escrita**
4. **Tente criar um novo usuário através da tela de cadastro**

### Logs de Debug

Os logs agora incluem:

- `[LOGIN_SCREEN]` - Ações na tela de login
- `[USER_NOTIFIER]` - Ações no provider do usuário
- `[LOGIN]` - Ações no serviço de autenticação
- `[AUTH]` - Ações gerais de autenticação

### Regras do Firestore

Certifique-se de que as regras do Firestore permitem leitura e escrita:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{userId} {
      allow read, write: if true; // Para desenvolvimento
    }
  }
}
```

### Contato

Se o problema persistir, verifique os logs completos e compartilhe as mensagens de erro específicas.
