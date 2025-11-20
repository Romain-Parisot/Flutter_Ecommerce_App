# ShopFlutter

Sujet: un e-commerce spécialisé dans la vente de bois de chauffage pour particuliers.

Application Flutter MVVM qui couvre l’intégralité d’un parcours e-commerce
sur Web/Android/iOS : catalogue filtrable, fiche produit, panier persistant, checkout simulé et historique des commandes.

## Fonctionnalités principales

- Catalogue & recherche : JSON mis en cache localement, filtres bois/prix chargement
	asynchrone via `CatalogNotifier`.
- Détails produit : galerie, specs, ajout au panier, bouton de partage Android, UI Cupertino iOS.
- Panier persistant (`SharedPreferences`) : quantités éditables, suppression, total, navigation vers
	le checkout.
- Checkout mocké : création d’un `Order` avec UUID, vidage du panier, snackbar de confirmation.
- Commandes : liste paginée rafraîchissable, données stockées côté client.

## Authentification

- Firebase Auth email/mot de passe pour la production (configurer `lib/firebase_options.dart` via
	`flutterfire configure`).
- Tant que le fichier contient les valeurs placeholder, un backend local persistant prend le relais
	pour permettre des tests rapides.
- Google Sign-In et mode démo (session anonyme) sont disponibles.

## Adaptations plateformes

- **Web** : PWA manifest + service worker + bannière d’installation custom.
- **Android** : partage natif (`share_plus`) sur la fiche produit.
- **iOS** : fiche produit rendue dans un `CupertinoPageScaffold`.

## Lancer le projet

```powershell
flutter pub get
flutter run
```

## Tests & couverture

- `flutter test --coverage` génère `coverage/lcov.info`.
- `dart run tool/coverage_summary.dart` affiche la synthèse et échoue si la variable d’environnement
	`MIN_COVERAGE` est définie et non respectée (CI → seuil 50 %).
- Suite de tests unitaires (notifiers, repositories, modèles) + widget tests, dont
	`test/full_app_flow_test.dart` qui couvre le flux complet.

## CI/CD GitHub Actions

- Workflow `.github/workflows/ci_cd.yml` : Flutter installé, dépendances, tests + couverture, build web,
	installation Node 20, `vercel` CLI puis `vercel deploy build/web --prod --yes`.
- Variables/flgs : `MIN_COVERAGE=50` pour le step de contrôle.
- Secrets requis (`Settings > Secrets and variables > Actions`) : `VERCEL_TOKEN`, `VERCEL_ORG_ID`,
	`VERCEL_PROJECT_ID`.

## Checklist du sujet

- [x] Parcours complet catalogue → produit → panier → checkout → commandes.
- [x] Architecture `go_router` + guard + repositories/cache.
- [x] Auth Firebase email/password (fallback local) + Google Sign-In.
- [x] Adaptations Web/Android/iOS.
- [x] Tests unitaires & widgets + couverture ≥ 50 %.
- [x] CI/CD GitHub Actions avec build web + déploiement Vercel.
- [ ] Bonus Stripe / publication store : non traité.
