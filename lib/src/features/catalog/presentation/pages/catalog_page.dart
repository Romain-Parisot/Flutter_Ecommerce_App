import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_3/src/core/widgets/page_with_nav_overlay.dart';
import '../../application/catalog_notifier.dart';
import '../widgets/product_card.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(catalogListProvider);
    final searchQuery = ref.watch(catalogSearchQueryProvider);
    final selectedWoodType = ref.watch(catalogWoodTypeFilterProvider);
    final maxPriceFilter = ref.watch(catalogMaxPriceFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue bois de chauffage'),
        actions: [
          IconButton(
            tooltip: 'Panier',
            onPressed: () => context.go('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: PageWithNavOverlay(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une essence, un diamètre, un format…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) =>
                      ref.read(catalogSearchQueryProvider.notifier).state =
                          value,
                ),
              ),
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    final woodTypes =
                        products.map((p) => p.woodType).toSet().toList()
                          ..sort();
                    final minPrice = products
                        .map((p) => p.price)
                        .reduce(
                          (value, element) => value < element ? value : element,
                        );
                    final maxPrice = products
                        .map((p) => p.price)
                        .reduce(
                          (value, element) => value > element ? value : element,
                        );
                    final effectiveMaxPrice = (maxPriceFilter ?? maxPrice)
                        .clamp(minPrice, maxPrice);

                    final filtered = products.where((product) {
                      final query = searchQuery.toLowerCase();
                      final matchesSearch =
                          searchQuery.isEmpty ||
                          product.title.toLowerCase().contains(query) ||
                          product.woodType.toLowerCase().contains(query) ||
                          product.category.toLowerCase().contains(query);
                      final matchesWoodType =
                          selectedWoodType == null ||
                          product.woodType == selectedWoodType;
                      final matchesPrice = product.price <= effectiveMaxPrice;
                      return matchesSearch && matchesWoodType && matchesPrice;
                    }).toList();

                    Widget listContent;
                    if (filtered.isEmpty) {
                      listContent = const Center(
                        child: Text(
                          'Aucune offre ne correspond aux filtres sélectionnés.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      listContent = RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(catalogListProvider);
                          await ref.read(catalogListProvider.future);
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: filtered[index]);
                          },
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _CatalogFiltersCard(
                            woodTypes: woodTypes,
                            selectedWoodType: selectedWoodType,
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            currentMaxPrice: effectiveMaxPrice,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: listContent),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Impossible de charger les produits'),
                        const SizedBox(height: 8),
                        Text('$error'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => ref.invalidate(catalogListProvider),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogFiltersCard extends ConsumerWidget {
  const _CatalogFiltersCard({
    required this.woodTypes,
    required this.selectedWoodType,
    required this.minPrice,
    required this.maxPrice,
    required this.currentMaxPrice,
  });

  final List<String> woodTypes;
  final String? selectedWoodType;
  final double minPrice;
  final double maxPrice;
  final double currentMaxPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final woodTypeNotifier = ref.read(catalogWoodTypeFilterProvider.notifier);
    final maxPriceNotifier = ref.read(catalogMaxPriceFilterProvider.notifier);
    final sliderDisabled = minPrice == maxPrice;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer les offres',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Toutes les essences'),
                  selected: selectedWoodType == null,
                  onSelected: (_) => woodTypeNotifier.state = null,
                ),
                for (final type in woodTypes)
                  ChoiceChip(
                    label: Text(type),
                    selected: selectedWoodType == type,
                    onSelected: (_) => woodTypeNotifier.state =
                        selectedWoodType == type ? null : type,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prix maximum'),
                Text('${currentMaxPrice.toStringAsFixed(0)} €'),
              ],
            ),
            Slider(
              value: currentMaxPrice,
              min: minPrice,
              max: maxPrice,
              onChanged: sliderDisabled
                  ? null
                  : (value) => maxPriceNotifier.state = value,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  woodTypeNotifier.state = null;
                  maxPriceNotifier.state = null;
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
