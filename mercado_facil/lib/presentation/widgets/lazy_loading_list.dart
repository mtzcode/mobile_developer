import 'package:flutter/material.dart';

/// Widget genérico para lazy loading que pode ser usado em todas as páginas
class LazyLoadingList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMoreItems;
  final bool isLoading;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final double? itemExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  const LazyLoadingList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMoreItems,
    required this.isLoading,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.scrollController,
    this.padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
  });

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!widget.hasMoreItems || widget.isLoading || _isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      await widget.onLoadMore();
    } catch (e) {
      // Erro silencioso - pode ser tratado pelo widget pai
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? 
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum item encontrado',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      itemCount: widget.items.length + (widget.hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          // Widget de loading no final
          return widget.loadingWidget ?? 
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
        
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}

/// Widget otimizado para listas de produtos com lazy loading
class LazyProductList extends StatelessWidget {
  final List<dynamic> produtos;
  final Widget Function(BuildContext context, dynamic produto, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMoreItems;
  final bool isLoading;
  final ScrollController? scrollController;

  const LazyProductList({
    super.key,
    required this.produtos,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMoreItems,
    required this.isLoading,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LazyLoadingList(
      items: produtos,
      itemBuilder: itemBuilder,
      onLoadMore: onLoadMore,
      hasMoreItems: hasMoreItems,
      isLoading: isLoading,
      scrollController: scrollController,
      padding: const EdgeInsets.all(16),
      emptyWidget: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum produto encontrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      loadingWidget: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Carregando mais produtos...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para lazy loading de categorias
class LazyCategoryList extends StatelessWidget {
  final List<String> categorias;
  final String categoriaSelecionada;
  final Function(String) onCategoriaSelected;
  final ScrollController? scrollController;

  const LazyCategoryList({
    super.key,
    required this.categorias,
    required this.categoriaSelecionada,
    required this.onCategoriaSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final isSelected = categoria == categoriaSelecionada;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(categoria),
              selected: isSelected,
              onSelected: (_) => onCategoriaSelected(categoria),
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
} 