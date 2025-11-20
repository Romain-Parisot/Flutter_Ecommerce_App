import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_3/src/core/widgets/page_with_nav_overlay.dart';

import '../../../cart/application/cart_controller.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../orders/application/orders_controller.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  bool _isProcessing = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout(List<CartItem> items) async {
    if (_isProcessing || items.isEmpty) return;
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    final ordersNotifier = ref.read(ordersControllerProvider.notifier);
    final order = await ordersNotifier.createOrderFromCart(items);
    await ref.read(cartControllerProvider.notifier).clearCart();
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande #${order.id.substring(0, 8)} confirmée !'),
      ),
    );
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout sécurisé')),
      body: PageWithNavOverlay(
        child: SafeArea(
          child: cartAsync.when(
            data: (cart) {
              if (cart.isEmpty) {
                return const Center(
                  child: Text(
                    'Panier vide – retournez au catalogue pour ajouter du bois.',
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          const Text(
                            'Résumé de commande',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...cart.items.map(
                            (item) => ListTile(
                              title: Text(
                                '${item.quantity}x ${item.product.title}',
                              ),
                              subtitle: Text(
                                '${item.product.steres} stère • ${item.product.woodType}',
                              ),
                              trailing: Text(
                                '${item.lineTotal.toStringAsFixed(2)} €',
                              ),
                            ),
                          ),
                          const Divider(height: 32),
                          ListTile(
                            title: const Text('Total TTC'),
                            trailing: Text(
                              '${cart.total.toStringAsFixed(2)} €',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText:
                                  'Instructions de livraison (optionnel)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _handleCheckout(cart.items),
                        icon: _isProcessing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.fireplace_outlined),
                        label: Text(
                          _isProcessing
                              ? 'Paiement en cours…'
                              : 'Confirmer et payer',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Erreur: $error')),
          ),
        ),
      ),
    );
  }
}
