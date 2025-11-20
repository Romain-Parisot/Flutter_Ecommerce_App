import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/catalog/presentation/pages/product_detail_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: notifier.handleRedirect,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) =>
            ProductDetailPage(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _subscription = _ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  String? handleRedirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!authState.isAuthenticated) {
      return isAuthRoute ? null : '/login';
    }

    if (isAuthRoute && authState.isAuthenticated) {
      return '/home';
    }

    return null;
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
