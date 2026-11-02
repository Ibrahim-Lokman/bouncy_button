import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

import '../data/mock_backend.dart';
import '../data/models.dart';
import '../state/demo_scope.dart';
import '../widgets/state_view.dart';

/// A mock store that shows loading, empty, and failed states.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Product>? _products;
  Set<String> _favorites = {};
  String? _error;
  bool _loading = true;

  /// Identifies the latest load, so an older one can't overwrite its result.
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadId = ++_loadId;
    final scope = DemoScope.read(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await scope.backend.fetchProducts();
      if (!mounted || loadId != _loadId) {
        return;
      }
      setState(() {
        _products = products;
        _favorites = scope.backend.favorites.toSet();
        _loading = false;
      });
      scope.log.add('Loaded ${products.length} products');
    } on MockApiException catch (error) {
      if (!mounted || loadId != _loadId) {
        return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
      scope.log.add('Loading products failed: ${error.failure.name}');
    }
  }

  /// Updates the heart immediately, and rolls back if the request fails.
  Future<void> _toggleFavorite(Product product) async {
    final scope = DemoScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final favorite = !_favorites.contains(product.id);
    setState(() => _setLocalFavorite(product.id, favorite));
    try {
      await scope.backend.setFavorite(product.id, favorite: favorite);
      scope.log.add('${favorite ? 'Saved' : 'Removed'} ${product.name}');
    } on MockApiException catch (error) {
      if (mounted) {
        setState(() => _setLocalFavorite(product.id, !favorite));
      }
      scope.log.add('Favorite rolled back: ${error.failure.name}');
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _setLocalFavorite(String id, bool favorite) {
    if (favorite) {
      _favorites.add(id);
    } else {
      _favorites.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _products;
    // Keep showing existing products during a pull to refresh or failed reload.
    if (products == null && _loading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading products'),
      );
    }
    if (products == null || (_error != null && products.isEmpty)) {
      return StateView(
        icon: Icons.cloud_off,
        title: 'Could not load products',
        message: _error ?? 'Something went wrong.',
        actionLabel: 'Try again',
        onAction: _load,
      );
    }
    if (products.isEmpty) {
      return StateView(
        icon: Icons.inventory_2_outlined,
        title: 'Nothing here yet',
        message: 'The catalog is empty. Turn off "Empty catalog" in Settings, '
            'then reload.',
        actionLabel: 'Reload',
        onAction: _load,
      );
    }
    return Column(
      children: [
        if (_error != null)
          MaterialBanner(
            content: Text(_error!),
            actions: [
              TextButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  product: product,
                  isFavorite: _favorites.contains(product.id),
                  onFavorite: () => _toggleFavorite(product),
                  onOpen: () =>
                      DemoScope.read(context).log.add('Opened ${product.name}'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onOpen,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final favoriteLabel = isFavorite
        ? 'Remove ${product.name} from favorites'
        : 'Add ${product.name} to favorites';
    // The whole card is pressable, with a separate pressable heart inside it.
    // Pressing the heart leaves the card still.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BouncyPressable(
        onTap: onOpen,
        scaleFactor: 0.97,
        // The heart inside must stay separately reachable by screen readers.
        semanticsButton: false,
        focusColor: theme.colorScheme.primary,
        focusBorderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: product.color,
                  foregroundColor: Colors.white,
                  child: Icon(product.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: textTheme.titleMedium),
                      Text(product.description, style: textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(formatPrice(product.priceCents)),
                    ],
                  ),
                ),
                Tooltip(
                  message: favoriteLabel,
                  excludeFromSemantics: true,
                  child: BouncyPressable(
                    onTap: onFavorite,
                    scaleFactor: 0.8,
                    haptic: BouncyHapticFeedbackType.selection,
                    semanticLabel: favoriteLabel,
                    focusColor: theme.colorScheme.primary,
                    focusBorderRadius:
                        const BorderRadius.all(Radius.circular(24)),
                    child: SizedBox.square(
                      dimension: 48,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.pink : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
