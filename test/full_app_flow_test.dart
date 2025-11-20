import 'dart:async';

import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:flutter_application_3/src/app.dart';
import 'package:flutter_application_3/src/core/widgets/page_with_nav_overlay.dart';
import 'package:flutter_application_3/src/features/auth/application/auth_backend.dart';
import 'package:flutter_application_3/src/features/catalog/domain/entities/product.dart';
import 'package:flutter_application_3/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_application_3/src/features/catalog/application/catalog_notifier.dart';

class _FlowAuthBackend implements AuthBackend {
  final _controller = StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  void _emit(AuthSession? session) {
    _session = session;
    _controller.add(session);
  }

  @override
  Stream<AuthSession?> get authStateChanges => _controller.stream;

  @override
  AuthSession? get currentUser => _session;

  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _emit(AuthSession(isAnonymous: false, email: email));
  }

  @override
  Future<void> signInAnonymously() async {
    _emit(const AuthSession(isAnonymous: true));
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _emit(AuthSession(isAnonymous: false, email: email));
  }

  @override
  Future<void> signInWithGoogle() async {
    _emit(const AuthSession(isAnonymous: false, email: 'google@test.app'));
  }

  @override
  Future<void> signOut() async {
    _emit(null);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this._products);

  final List<Product> _products;

  @override
  Future<Product> fetchProduct(String id) async {
    return _products.firstWhere((element) => element.id == id);
  }

  @override
  Future<List<Product>> fetchProducts() async {
    return _products;
  }
}

Product _product(String id, double price) {
  return Product(
    id: id,
    title: 'Premium $id',
    price: price,
    thumbnail: 'https://example.com/$id-thumb.jpg',
    images: ['https://example.com/$id.jpg'],
    description: 'Produit $id',
    category: 'bois',
    steres: 1.2,
    logLengthCm: 33,
    logDiameterCm: 8,
    woodType: 'Chêne',
    dryness: '15%',
    availabilityDays: 4,
  );
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.window.devicePixelRatioTestValue = 1.0;
    binding.window.physicalSizeTestValue = const ui.Size(480, 960);
    addTearDown(() {
      binding.window.clearDevicePixelRatioTestValue();
      binding.window.clearPhysicalSizeTestValue();
      PageWithNavOverlay.testOverride = null;
    });
    SharedPreferences.setMockInitialValues({});
    PageWithNavOverlay.testOverride = (_, child) => child;
  });

  testWidgets('end-to-end happy path covers main screens', (tester) async {
    final backend = _FlowAuthBackend();
    final catalog = _FakeCatalogRepository([
      _product('A', 80),
      _product('B', 60),
    ]);
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authBackendProvider.overrideWithValue(backend),
            catalogRepositoryProvider.overrideWithValue(catalog),
          ],
          child: const ShopApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Connexion email'), findsOneWidget);

      await tester.tap(find.text('Connexion email'));
      await tester.pumpAndSettle();

      expect(find.text('Accueil'), findsWidgets);
      await tester.tap(find.text('Catalogue').first);
      await tester.pumpAndSettle();

      expect(find.text('Premium A'), findsWidgets);
      await tester.tap(find.text('Premium A').first);
      await tester.pumpAndSettle();

      expect(find.text('Ajouter au panier'), findsOneWidget);
      await tester.tap(find.text('Ajouter au panier'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Voir'));
      await tester.pumpAndSettle();
      expect(find.text('Premium A'), findsWidgets);

      await tester.tap(find.text('Passer au checkout'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmer et payer'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Commandes'), findsWidgets);
      expect(find.textContaining('Commande #'), findsWidgets);
    });
  });
}
