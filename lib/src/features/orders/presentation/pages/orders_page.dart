import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_3/src/core/widgets/page_with_nav_overlay.dart';
import '../../application/orders_controller.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersControllerProvider);
    final dateFormatter = DateFormat('dd MMM yyyy – HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      body: PageWithNavOverlay(
        child: SafeArea(
          child: ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune commande pour le moment. Lancez un feu !',
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(ordersControllerProvider);
                  await ref.read(ordersControllerProvider.future);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      child: ListTile(
                        title: Text('Commande #${order.id.substring(0, 8)}'),
                        subtitle: Text(
                          '${order.items.length} articles • ${order.status}\n${dateFormatter.format(order.createdAt)}',
                        ),
                        trailing: Text('${order.total.toStringAsFixed(2)} €'),
                      ),
                    );
                  },
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
