import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_3/src/core/widgets/page_with_nav_overlay.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../pwa/application/pwa_install_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: PageWithNavOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour ${authState.email ?? 'boiseux'} 👋',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bienvenue sur ShopFlutter – Bois de chauffage premium et local.',
                ),
                if (kIsWeb) ...const [
                  SizedBox(height: 20),
                  _PwaInstallBanner(),
                ],
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _HomeActionCard(
                      title: 'Catalogue',
                      subtitle: 'Bûches, pellets, allume-feu',
                      icon: Icons.local_fire_department_outlined,
                      onTap: () => context.go('/catalog'),
                    ),
                    _HomeActionCard(
                      title: 'Panier',
                      subtitle: 'Vérifier les quantités',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => context.go('/cart'),
                    ),
                    _HomeActionCard(
                      title: 'Commandes',
                      subtitle: 'Historique & suivi',
                      icon: Icons.receipt_long_outlined,
                      onTap: () => context.go('/orders'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32),
                const SizedBox(height: 24),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PwaInstallBanner extends ConsumerWidget {
  const _PwaInstallBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pwaInstallControllerProvider);
    if (!state.canInstall) {
      return const SizedBox.shrink();
    }
    final notifier = ref.read(pwaInstallControllerProvider.notifier);
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Installer ShopFlutter sur cet appareil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Accédez au catalogue bois de chauffage directement depuis votre écran d’accueil et hors navigateur.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: state.isPrompting
                  ? null
                  : () async {
                      final success = await notifier.promptInstall();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Fenêtre d’installation ouverte. Validez l’invite de votre navigateur.'
                                : 'Impossible d’ouvrir l’invite d’installation.',
                          ),
                        ),
                      );
                    },
              icon: state.isPrompting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(
                state.isPrompting
                    ? 'Invitation envoyée…'
                    : 'Ajouter ShopFlutter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
