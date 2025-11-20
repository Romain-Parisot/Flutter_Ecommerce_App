import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrimaryNavBar extends StatelessWidget {
  const PrimaryNavBar({super.key});

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Accueil',
      route: '/',
    ),
    _NavItem(
      icon: Icons.local_fire_department_outlined,
      selectedIcon: Icons.local_fire_department,
      label: 'Catalogue',
      route: '/catalog',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Panier',
      route: '/cart',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Commandes',
      route: '/orders',
    ),
    _NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profil',
      route: '/profile',
    ),
  ];

  int _indexForLocation(String path) {
    final index = _items.indexWhere((item) => item.matches(path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final path = state.uri.path;
    final selectedIndex = _indexForLocation(path);

    return Material(
      elevation: 12,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 68,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            final item = _items[index];
            if (!item.matches(path)) {
              context.go(item.route);
            }
          },
          destinations: [
            for (final item in _items)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon ?? item.icon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String route;

  bool matches(String location) {
    if (route == '/') {
      return location == '/' || location.isEmpty;
    }
    return location == route || location.startsWith('$route/');
  }
}
