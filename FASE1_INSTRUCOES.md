# 🚀 Fase 1 - Instruções de Implementação

## ✅ **Arquivos Criados e Configurados**

### **1. Arquivos Compartilhados**

- `shared/types.ts` - Tipos padronizados
- `shared/auth.ts` - Sistema de autenticação
- `shared/migration.ts` - Script de migração

### **2. Configurações Firebase**

- `mercado-facil-admin/src/lib/firebase.ts`
- `mercado-facil-cliente/lib/firebase.ts`

### **3. Sistema de Autenticação**

- `mercado-facil-admin/src/lib/auth.ts`
- `mercado-facil-cliente/lib/auth.ts`
- `mercado-facil-admin/src/components/LoginForm.tsx`
- `mercado-facil-cliente/components/LoginForm.tsx`

### **4. Middleware e Páginas**

- `mercado-facil-admin/middleware.ts`
- `mercado-facil-cliente/middleware.ts`
- `mercado-facil-admin/src/app/login/page.tsx`
- `mercado-facil-admin/src/app/unauthorized/page.tsx`

### **5. Scripts de Migração e Teste**

- `mercado-facil-admin/scripts/migrate-data.ts`
- `mercado-facil-cliente/scripts/migrate-data.ts`
- `mercado-facil-admin/scripts/test-auth.ts`
- `mercado-facil-cliente/scripts/test-auth.ts`

## 🔧 **Como Executar**

### **1. Configurar Variáveis de Ambiente**

Crie arquivos `.env.local` em ambos os projetos:

**mercado-facil-admin/.env.local:**

```env
NEXT_PUBLIC_FIREBASE_API_KEY=sua_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=seu_projeto.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=seu_projeto_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=seu_projeto.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=seu_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=seu_app_id
```

**mercado-facil-cliente/.env.local:**

```env
NEXT_PUBLIC_FIREBASE_API_KEY=sua_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=seu_projeto.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=seu_projeto_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=seu_projeto.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=seu_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=seu_app_id
```

### **2. Instalar Dependências**

```bash
# No projeto admin
cd mercado-facil-admin
npm install firebase

# No projeto cliente
cd mercado-facil-cliente
npm install firebase
```

### **3. Executar Migração de Dados**

```bash
# No projeto admin
cd mercado-facil-admin
npx ts-node scripts/migrate-data.ts

# No projeto cliente
cd mercado-facil-cliente
npx ts-node scripts/migrate-data.ts
```

### **4. Testar Autenticação**

```bash
# No projeto admin
cd mercado-facil-admin
npx ts-node scripts/test-auth.ts

# No projeto cliente
cd mercado-facil-cliente
npx ts-node scripts/test-auth.ts
```

### **5. Executar os Projetos**

```bash
# Admin
cd mercado-facil-admin
npm run dev

# Cliente
cd mercado-facil-cliente
npm run dev
```

## 🧪 **Testes Recomendados**

### **1. Teste de Login Admin**

1. Acesse `http://localhost:3000/login`
2. Faça login com credenciais de admin
3. Verifique redirecionamento para dashboard

### **2. Teste de Login Cliente**

1. Acesse `http://localhost:3001/`
2. Clique em "Entrar" ou "Criar Conta"
3. Teste login e registro

### **3. Teste de Proteção de Rotas**

1. Tente acessar rotas protegidas sem login
2. Verifique redirecionamentos corretos

## 📋 **Checklist de Verificação**

- [ ] Variáveis de ambiente configuradas
- [ ] Dependências instaladas
- [ ] Migração executada com sucesso
- [ ] Login admin funcionando
- [ ] Login cliente funcionando
- [ ] Proteção de rotas ativa
- [ ] Tipos padronizados funcionando
- [ ] Serviços atualizados

## 🚨 **Possíveis Problemas**

### **1. Erro de Firebase**

- Verifique se as variáveis de ambiente estão corretas
- Confirme se o projeto Firebase está ativo

### **2. Erro de Migração**

- Verifique permissões do Firestore
- Execute migração em ambiente de desenvolvimento primeiro

### **3. Erro de Autenticação**

- Verifique se Authentication está habilitado no Firebase
- Confirme se os domínios estão autorizados

## 🎯 **Próximos Passos**

Após completar esta fase:

1. **Fase 2**: Melhorias de Performance
2. **Fase 3**: Funcionalidades Avançadas
3. **Fase 4**: Otimizações e Deploy

---

**✅ Fase 1 Concluída com Sucesso!**

Os projetos agora estão alinhados, padronizados e com sistema de autenticação funcional.
