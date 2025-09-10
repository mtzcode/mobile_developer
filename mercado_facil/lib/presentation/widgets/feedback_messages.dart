import 'package:flutter/material.dart';
import '../../core/utils/snackbar_utils.dart';

/// Mensagens de sucesso
abstract class FeedbackSuccess {
  static const String productAdded = 'Produto adicionado ao carrinho!';
  static const String productRemoved = 'Produto removido do carrinho!';
  static const String orderPlaced = 'Pedido realizado com sucesso!';
  static const String profileUpdated = 'Perfil atualizado com sucesso!';
  static const String addressAdded = 'Endereço adicionado com sucesso!';
  static const String addressUpdated = 'Endereço atualizado com sucesso!';
  static const String addressRemoved = 'Endereço removido com sucesso!';
  static const String passwordChanged = 'Senha alterada com sucesso!';
  static const String emailSent = 'E-mail enviado com sucesso!';
  static const String dataSaved = 'Dados salvos com sucesso!';
  static const String cacheCleared = 'Cache limpo com sucesso!';
  static const String productsUpdated = 'Produtos atualizados com sucesso!';
  static const String loginSuccessful = 'Login realizado com sucesso!';
  static const String logoutSuccessful = 'Logout realizado com sucesso!';
  static const String registrationSuccessful = 'Cadastro realizado com sucesso!';
}

/// Mensagens de erro
abstract class FeedbackError {
  static const String networkError = 'Erro de conexão. Verifique sua internet.';
  static const String serverError = 'Erro no servidor. Tente novamente.';
  static const String timeoutError = 'Tempo limite excedido. Tente novamente.';
  static const String authenticationError = 'Erro de autenticação. Faça login novamente.';
  static const String validationError = 'Dados inválidos. Verifique as informações.';
  static const String productNotFound = 'Produto não encontrado.';
  static const String orderNotFound = 'Pedido não encontrado.';
  static const String insufficientStock = 'Estoque insuficiente.';
  static const String paymentError = 'Erro no pagamento. Tente novamente.';
  static const String fileUploadError = 'Erro ao fazer upload do arquivo.';
  static const String imageLoadError = 'Erro ao carregar imagem.';
  static const String cacheError = 'Erro ao acessar cache.';
  static const String unknownError = 'Erro inesperado. Tente novamente.';
  static const String loginFailed = 'Falha no login. Verifique suas credenciais.';
  static const String registrationFailed = 'Falha no cadastro. Tente novamente.';
  static const String passwordResetFailed = 'Falha ao redefinir senha.';
  static const String emailInvalid = 'E-mail inválido.';
  static const String passwordWeak = 'Senha muito fraca.';
  static const String cpfInvalid = 'CPF inválido.';
  static const String phoneInvalid = 'Telefone inválido.';
  static const String cepInvalid = 'CEP inválido.';
}

/// Mensagens de aviso
abstract class FeedbackWarning {
  static const String slowConnection = 'Conexão lenta detectada.';
  static const String lowBattery = 'Bateria baixa.';
  static const String storageFull = 'Armazenamento cheio.';
  static const String outdatedApp = 'Versão desatualizada do app.';
  static const String locationRequired = 'Localização necessária para entrega.';
  static const String cameraPermission = 'Permissão de câmera necessária.';
  static const String notificationPermission = 'Permissão de notificação necessária.';
  static const String dataUsage = 'Uso de dados detectado.';
  static const String weakSignal = 'Sinal fraco detectado.';
  static const String cacheExpired = 'Cache expirado. Atualizando...';
}

/// Mensagens informativas
abstract class FeedbackInfo {
  static const String loading = 'Carregando...';
  static const String saving = 'Salvando...';
  static const String updating = 'Atualizando...';
  static const String searching = 'Pesquisando...';
  static const String processing = 'Processando...';
  static const String connecting = 'Conectando...';
  static const String downloading = 'Baixando...';
  static const String uploading = 'Fazendo upload...';
  static const String syncing = 'Sincronizando...';
  static const String refreshing = 'Atualizando...';
}

/// Classe utilitária para exibir mensagens de feedback
class FeedbackUtils {
  /// Exibir mensagem de sucesso
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showAppSnackBar(
      context,
      message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade600,
      duration: duration ?? const Duration(seconds: 3),
      action: (onAction != null && actionLabel != null) 
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
    );
  }

  /// Exibir mensagem de erro
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showAppSnackBar(
      context,
      message,
      icon: Icons.error,
      backgroundColor: Colors.red.shade600,
      duration: duration ?? const Duration(seconds: 4),
      action: (onAction != null && actionLabel != null) 
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
    );
  }

  /// Exibir mensagem de aviso
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showAppSnackBar(
      context,
      message,
      icon: Icons.warning,
      backgroundColor: Colors.orange.shade600,
      duration: duration ?? const Duration(seconds: 3),
      action: (onAction != null && actionLabel != null) 
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
    );
  }

  /// Exibir mensagem informativa
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showAppSnackBar(
      context,
      message,
      icon: Icons.info,
      backgroundColor: Colors.blue.shade600,
      duration: duration ?? const Duration(seconds: 3),
      action: (onAction != null && actionLabel != null) 
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
    );
  }

  /// Exibir diálogo de confirmação
  static Future<bool> showConfirmation(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Exibir diálogo de erro
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String buttonText = 'OK',
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Tentar Novamente'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}