import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_3/src/core/widgets/page_with_nav_overlay.dart';
import 'package:flutter_application_3/src/features/auth/application/auth_controller.dart';
import 'package:flutter_application_3/src/features/cart/application/cart_controller.dart';
import 'package:flutter_application_3/src/features/orders/application/orders_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final ordersAsync = ref.watch(ordersControllerProvider);
    final cartAsync = ref.watch(cartControllerProvider);

    final ordersCount = ordersAsync.maybeWhen(
      data: (orders) => orders.length,
      orElse: () => null,
    );
    final cartItems = cartAsync.maybeWhen(
      data: (cart) => cart.items.length,
      orElse: () => null,
    );
    final cartTotal = cartAsync.maybeWhen(
      data: (cart) => cart.total,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: PageWithNavOverlay(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      authState.isAuthenticated
                          ? Icons.person
                          : Icons.person_outline,
                    ),
                  ),
                  title: Text(authState.email ?? 'Session locale'),
                  subtitle: Text(
                    authState.isAuthenticated
                        ? 'Connecté via Firebase'
                        : 'Mode démo / hors ligne',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Activité',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Commandes',
                      value: ordersCount != null ? '$ordersCount' : '—',
                      icon: Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Articles panier',
                      value: cartItems != null ? '$cartItems' : '—',
                      icon: Icons.shopping_cart,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatCard(
                label: 'Total panier',
                value:
                    cartTotal != null ? '${cartTotal.toStringAsFixed(2)} €' : '—',
                icon: Icons.payments,
              ),
              const SizedBox(height: 24),
              Text(
                'Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                },
                icon: authState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(
                  authState.isLoading ? 'Déconnexion…' : 'Se déconnecter',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ref.invalidate(cartControllerProvider);
                  ref.invalidate(ordersControllerProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Recharger les données locales'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
