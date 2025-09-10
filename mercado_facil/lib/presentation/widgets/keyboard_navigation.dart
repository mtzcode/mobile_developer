import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de navegação por teclado
class KeyboardNavigation {
  static final FocusNode _primaryFocusNode = FocusNode();
  static final Map<String, FocusNode> _focusNodes = {};
  
  /// Configura navegação por teclado para uma tela
  static Widget wrapWithKeyboardNavigation({
    required Widget child,
    required String screenId,
    List<String> focusableIds = const [],
  }) {
    return Focus(
      autofocus: true,
      focusNode: _primaryFocusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event, screenId, focusableIds);
        return KeyEventResult.handled;
      },
      child: child,
    );
  }
  
  /// Registra um widget focável
  static void registerFocusable(String id, FocusNode focusNode) {
    _focusNodes[id] = focusNode;
  }
  
  /// Remove registro de widget focável
  static void unregisterFocusable(String id) {
    _focusNodes.remove(id);
  }
  
  /// Foca em um widget específico
  static void focusOn(String id) {
    final focusNode = _focusNodes[id];
    if (focusNode != null) {
      focusNode.requestFocus();
    }
  }
  
  /// Move foco para o próximo widget
  static void focusNext(String currentId, List<String> focusableIds) {
    final currentIndex = focusableIds.indexOf(currentId);
    if (currentIndex >= 0 && currentIndex < focusableIds.length - 1) {
      focusOn(focusableIds[currentIndex + 1]);
    }
  }
  
  /// Move foco para o widget anterior
  static void focusPrevious(String currentId, List<String> focusableIds) {
    final currentIndex = focusableIds.indexOf(currentId);
    if (currentIndex > 0) {
      focusOn(focusableIds[currentIndex - 1]);
    }
  }
  
  /// Manipula eventos de teclado
  static void _handleKeyEvent(
    KeyEvent event,
    String screenId,
    List<String> focusableIds,
  ) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.tab:
          if (HardwareKeyboard.instance.isShiftPressed) {
            // Tab + Shift: foco anterior
            _handleTabNavigation(false, focusableIds);
          } else {
            // Tab: próximo foco
            _handleTabNavigation(true, focusableIds);
          }
          break;
        case LogicalKeyboardKey.arrowUp:
          _handleArrowNavigation('up', focusableIds);
          break;
        case LogicalKeyboardKey.arrowDown:
          _handleArrowNavigation('down', focusableIds);
          break;
        case LogicalKeyboardKey.arrowLeft:
          _handleArrowNavigation('left', focusableIds);
          break;
        case LogicalKeyboardKey.arrowRight:
          _handleArrowNavigation('right', focusableIds);
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          _handleActionKey();
          break;
        case LogicalKeyboardKey.escape:
          _handleEscapeKey();
          break;
      }
    }
  }
  
  /// Manipula navegação por Tab
  static void _handleTabNavigation(bool forward, List<String> focusableIds) {
    final currentFocus = _getCurrentFocusedId();
    if (currentFocus != null) {
      if (forward) {
        focusNext(currentFocus, focusableIds);
      } else {
        focusPrevious(currentFocus, focusableIds);
      }
    } else if (focusableIds.isNotEmpty) {
      focusOn(focusableIds.first);
    }
  }
  
  /// Manipula navegação por setas
  static void _handleArrowNavigation(String direction, List<String> focusableIds) {
    final currentFocus = _getCurrentFocusedId();
    if (currentFocus != null) {
      // Implementar lógica de navegação por setas baseada no layout
      switch (direction) {
        case 'up':
          _navigateUp(currentFocus, focusableIds);
          break;
        case 'down':
          _navigateDown(currentFocus, focusableIds);
          break;
        case 'left':
          _navigateLeft(currentFocus, focusableIds);
          break;
        case 'right':
          _navigateRight(currentFocus, focusableIds);
          break;
      }
    }
  }
  
  /// Navega para cima
  static void _navigateUp(String currentId, List<String> focusableIds) {
    // Implementar lógica baseada no layout da tela
    // Por enquanto, usa navegação sequencial
    focusPrevious(currentId, focusableIds);
  }
  
  /// Navega para baixo
  static void _navigateDown(String currentId, List<String> focusableIds) {
    focusNext(currentId, focusableIds);
  }
  
  /// Navega para a esquerda
  static void _navigateLeft(String currentId, List<String> focusableIds) {
    focusPrevious(currentId, focusableIds);
  }
  
  /// Navega para a direita
  static void _navigateRight(String currentId, List<String> focusableIds) {
    focusNext(currentId, focusableIds);
  }
  
  /// Manipula tecla de ação (Enter/Space)
  static void _handleActionKey() {
    final currentFocus = _getCurrentFocusedId();
    if (currentFocus != null) {
      // Simular tap no widget atual
      final focusNode = _focusNodes[currentFocus];
      if (focusNode != null && focusNode.hasFocus) {
        // Aqui você pode disparar a ação do widget
        // Por exemplo, se for um botão, simular o onPressed
      }
    }
  }
  
  /// Manipula tecla Escape
  static void _handleEscapeKey() {
    // Voltar ou fechar modal
    // Esta lógica pode ser customizada por tela
  }
  
  /// Obtém o ID do widget atualmente focado
  static String? _getCurrentFocusedId() {
    for (final entry in _focusNodes.entries) {
      if (entry.value.hasFocus) {
        return entry.key;
      }
    }
    return null;
  }
  
  /// Limpa todos os focus nodes
  static void dispose() {
    _primaryFocusNode.dispose();
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _focusNodes.clear();
  }
}

/// Widget para tornar um elemento focável por teclado
class KeyboardFocusable extends StatefulWidget {
  final String id;
  final Widget child;
  final VoidCallback? onActivate;
  final bool enabled;
  
  const KeyboardFocusable({
    super.key,
    required this.id,
    required this.child,
    this.onActivate,
    this.enabled = true,
  });

  @override
  State<KeyboardFocusable> createState() => _KeyboardFocusableState();
}

class _KeyboardFocusableState extends State<KeyboardFocusable> {
  late FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    KeyboardNavigation.registerFocusable(widget.id, _focusNode);
  }
  
  @override
  void dispose() {
    KeyboardNavigation.unregisterFocusable(widget.id);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onActivate?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}

/// Mixin para adicionar navegação por teclado a widgets
mixin KeyboardNavigationMixin {
  /// Lista de IDs focáveis na ordem de navegação
  List<String> get focusableIds => [];
  
  /// Configura navegação por teclado
  Widget wrapWithKeyboardNavigation(Widget child) {
    return KeyboardNavigation.wrapWithKeyboardNavigation(
      child: child,
      screenId: runtimeType.toString(),
      focusableIds: focusableIds,
    );
  }
  
  /// Foca no primeiro elemento
  void focusFirst() {
    if (focusableIds.isNotEmpty) {
      KeyboardNavigation.focusOn(focusableIds.first);
    }
  }
  
  /// Foca no último elemento
  void focusLast() {
    if (focusableIds.isNotEmpty) {
      KeyboardNavigation.focusOn(focusableIds.last);
    }
  }
}