/// Constantes para configuração do sistema de logging
class LoggingConstants {
  // Níveis de log
  static const String debug = 'DEBUG';
  static const String info = 'INFO';
  static const String warning = 'WARNING';
  static const String error = 'ERROR';
  static const String fatal = 'FATAL';

  // Categorias de log
  static const String api = 'API';
  static const String cache = 'CACHE';
  static const String auth = 'AUTH';
  static const String cart = 'CART';
  static const String order = 'ORDER';
  static const String product = 'PRODUCT';
  static const String ui = 'UI';
  static const String navigation = 'NAVIGATION';
  static const String performance = 'PERFORMANCE';
  static const String security = 'SECURITY';

  // Operações comuns
  static const String operationStart = 'START';
  static const String operationEnd = 'END';
  static const String operationSuccess = 'SUCCESS';
  static const String operationFailure = 'FAILURE';
  static const String operationWarning = 'WARNING';

  // Mensagens padrão
  static const String defaultErrorMessage = 'Erro desconhecido';
  static const String defaultSuccessMessage = 'Operação realizada com sucesso';
  static const String defaultWarningMessage = 'Aviso: operação pode ter problemas';

  // Configurações
  static const int maxLogLength = 1000; // Máximo de caracteres por log
  static const int maxStackTraceLines = 10; // Máximo de linhas de stack trace
  static const bool enableColors = true; // Habilitar cores no console
  static const bool enableEmojis = true; // Habilitar emojis
  static const bool enableTimestamps = true; // Habilitar timestamps
} 