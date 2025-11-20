import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_application_3/src/core/widgets/page_with_nav_overlay.dart';
import '../../../cart/application/cart_controller.dart';
import '../../application/catalog_notifier.dart';
import '../../domain/entities/product.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _quantity = 1;

  bool get _isCupertinoPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isAndroidPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void _updateQuantity(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 99);
    });
  }

  Future<void> _shareProduct(Product product) async {
    final message =
        '🔥 ${product.title}\n${product.price.toStringAsFixed(2)} € / '
        '${product.steres.toStringAsFixed(1)} stère\n'
        'Disponible sous ${product.availabilityDays} jours.';
    await Share.share(message, subject: 'Offre ShopFlutter – ${product.title}');
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    final content = PageWithNavOverlay(
      child: SafeArea(
        child: productAsync.when(
          data: (product) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.images.isNotEmpty
                      ? product.images.first
                      : product.thumbnail,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                product.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${product.price.toStringAsFixed(2)} € / '
                '${product.steres.toStringAsFixed(1)} stère',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(product.description),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _DetailChip(label: 'Essence', value: product.woodType),
                  _DetailChip(
                    label: 'Longueur',
                    value: '${product.logLengthCm} cm',
                  ),
                  _DetailChip(
                    label: 'Diamètre',
                    value: '${product.logDiameterCm} cm',
                  ),
                  _DetailChip(label: 'Humidité', value: product.dryness),
                  _DetailChip(
                    label: 'Disponibilité',
                    value: 'Sous ${product.availabilityDays} j',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantité',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _updateQuantity(-1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        _quantity.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => _updateQuantity(1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final router = GoRouter.of(context);
                  final quantity = _quantity;
                  await ref
                      .read(cartControllerProvider.notifier)
                      .addProduct(product, quantity: quantity);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        '${quantity}x ${product.title} ajouté au panier',
                      ),
                      action: SnackBarAction(
                        label: 'Voir',
                        onPressed: () => router.go('/cart'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Ajouter au panier'),
              ),
              if (_isAndroidPlatform)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Partager cette offre'),
                    onPressed: () => _shareProduct(product),
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur: $error')),
        ),
      ),
    );

    if (_isCupertinoPlatform) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Détail produit'),
        ),
        child: content,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Détail produit')),
      body: content,
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
