// Tipos compartilhados entre admin e cliente
// Este arquivo deve ser copiado para ambos os projetos

// ===== USUÁRIOS/CLIENTES =====
export interface User {
  id: string;
  nome: string;
  email: string;
  telefone: string;
  dataCadastro: Date;
  cadastroCompleto: boolean;
  ativo: boolean;
  ultimoLogin?: Date;
  enderecos?: Endereco[];
  // Campos de compatibilidade
  whatsapp?: string; // Alias para telefone
}

// Alias para compatibilidade
export type Cliente = User;
export type Usuario = User;

// ===== PRODUTOS =====
export interface Produto {
  id: string;
  nome: string;
  descricao?: string;
  codigoBarras?: string;
  preco: number;
  custo?: number;
  imagemUrl?: string;
  imagens?: string[];
  categoria: string;
  destaque?: boolean;
  disponivel: boolean;
  ativo: boolean;
  estoque: number;
  tipoUnidade?: string;
  unidadeMedida?: string;
  avaliacoes?: number[];
  tags?: string[];
  // Campos de promoção
  promocaoAtiva?: boolean;
  promocaoDataInicio?: Date;
  promocaoDataFinal?: Date;
  precoPromocional?: number;
  // Campos de compatibilidade
  promo_price?: number;
  promo_price_per_100g?: number;
  promo_status?: string;
  unit_type?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

// Alias para compatibilidade
export type Product = Produto;

// ===== CATEGORIAS =====
export interface Categoria {
  id: string;
  nome: string;
  descricao?: string;
  icone?: string;
  cor?: string;
  ordem?: number;
  ativa?: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

// Alias para compatibilidade
export type Category = Categoria;

// ===== ENDEREÇOS =====
export interface Endereco {
  id: string;
  userId: string; // Padronizado - sempre userId
  cep: string;
  logradouro: string;
  numero: string;
  complemento?: string;
  bairro: string;
  cidade: string;
  estado: string;
  principal: boolean;
  // Campos de compatibilidade
  clienteId?: string; // Deprecated - usar userId
  usuarioId?: string; // Deprecated - usar userId
}

// ===== CARRINHO =====
export interface CarrinhoItem {
  id: string;
  name: string;
  price: number;
  qty: number;
  barcode?: string;
  category?: string;
  // Campos de compatibilidade
  produto?: Produto;
  quantidade?: number;
  subtotal?: number;
}

// Alias para compatibilidade
export type CartItem = CarrinhoItem;

// ===== PEDIDOS =====
export interface Pedido {
  id: string;
  userId: string; // Padronizado - sempre userId
  itens: CarrinhoItem[];
  total: number;
  status:
    | "pendente"
    | "confirmado"
    | "preparando"
    | "saiu_entrega"
    | "entregue"
    | "cancelado";
  endereco: Endereco;
  dataPedido: Date;
  dataEntrega?: Date;
  observacoes?: string;
  metodoPagamento: string;
  // Campos de compatibilidade
  clienteId?: string; // Deprecated - usar userId
  usuarioId?: string; // Deprecated - usar userId
}

// Alias para compatibilidade
export type Order = Pedido;

// ===== NOTIFICAÇÕES =====
export interface Notificacao {
  id: string;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  timestamp: Date;
  read: boolean;
  userId?: string;
  type: "promocao" | "pedido" | "sistema" | "oferta";
}

// ===== DASHBOARD =====
export interface DashboardStats {
  totalClientes: number;
  totalProdutos: number;
  totalPedidos: number;
  totalVendas: number;
  pedidosPendentes: number;
  produtosSemEstoque: number;
}

// ===== PAGINAÇÃO =====
export interface DataPage<T> {
  items: T[];
  meta: {
    total: number;
    page: number;
    page_size: number;
    pages: number;
  };
}

// ===== FORMULÁRIOS =====
export interface ProdutoForm {
  nome: string;
  descricao: string;
  codigoBarras: string;
  preco: number;
  custo: number;
  imagemUrl: string;
  imagens: string[];
  categoria: string;
  destaque: boolean;
  disponivel: boolean;
  ativo: boolean;
  estoque: number;
  tipoUnidade: string;
  tags: string[];
  // Campos de promoção
  promocaoAtiva: boolean;
  promocaoDataInicio?: string;
  promocaoDataFinal?: string;
  precoPromocional?: number;
}

export interface CategoriaForm {
  nome: string;
  descricao: string;
  ativa: boolean;
  ordem: number;
}

export interface NotificacaoForm {
  title: string;
  body: string;
  type: "promocao" | "pedido" | "sistema" | "oferta";
  targetUsers?: string[];
  sendToAll: boolean;
  data?: Record<string, unknown>;
}

// ===== CONTEXTOS =====
export interface CartContextType {
  items: CarrinhoItem[];
  addItem: (item: Omit<CarrinhoItem, "qty">, qty?: number) => void;
  setQty: (id: string, qty: number) => void;
  remove: (id: string) => void;
  clear: () => void;
  count: number;
  subtotal: number;
  hydrated: boolean;
}

export interface FavoritesContextType {
  favorites: Produto[];
  addToFavorites: (product: Produto) => void;
  removeFromFavorites: (productId: string) => void;
  isFavorite: (productId: string) => boolean;
  clearFavorites: () => void;
  addAllToCart: () => void;
  hydrated: boolean;
}

// ===== UTILITÁRIOS =====
export type DeliveryMode = "pickup" | "delivery";

export interface PaymentMethod {
  id: string;
  name: string;
  description: string;
  icon: string;
}

export interface CustomerData {
  name: string;
  phone: string;
  address?: {
    street: string;
    number: string;
    complement: string;
    neighborhood: string;
    city: string;
    state: string;
    zipCode: string;
  };
}

// ===== ENUMS =====
export enum LogLevel {
  DEBUG = "debug",
  INFO = "info",
  WARN = "warn",
  ERROR = "error",
}

export interface LogContext {
  userId?: string;
  sessionId?: string;
  feature?: string;
  action?: string;
  metadata?: Record<string, unknown>;
  search?: string;
  count?: number;
  total?: number;
  error?: string;
  host?: string;
  query?: string;
  success?: boolean;
  message?: string;
  synced?: number | boolean;
  errors?: unknown[];
  database?: string;
  paramsCount?: number;
  status?: unknown;
  firebase?: number;
  page?: number;
  items_count?: number;
  source?: string;
}
