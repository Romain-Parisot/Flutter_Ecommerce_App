# ShopFlutter – Bois de chauffage

Application Flutter de démonstration pour parcourir un catalogue de bois de chauffage,
gérer un panier, passer commande et consulter l’historique. L’interface est optimisée
pour le web (PWA) et les plateformes mobiles.

## Authentification

- Identifiants par défaut : `demo@shopflutter.app` / `azerty123`
- Mode démo : bouton "Mode démo – accès immédiat" sur l’écran de connexion.

L’application détecte automatiquement si Firebase est configuré. Sans configuration
(`firebase_options.dart` contient encore les valeurs `REPLACE_WITH`), un backend
local persistant prend le relais : vos comptes sont stockés dans `SharedPreferences`
et les identifiants ci-dessus fonctionnent immédiatement après `flutter run`.

## Démarrage rapide

```powershell
flutter pub get
flutter run
```

Pour activer Firebase, remplacez les valeurs de `firebase_options.dart` en lançant
`flutterfire configure` puis relancez l’application.

## CI/CD GitHub Actions

Une pipeline automatisée est disponible dans `.github/workflows/ci_cd.yml`. Elle
est déclenchée sur chaque `push`/`pull request` vers `main` ainsi qu’à la demande
(`workflow_dispatch`). Les étapes exécutées sont :

1. Installation de Flutter (canal stable) et mise en cache des dépendances.
2. `flutter pub get` puis `flutter test --coverage` pour garantir la qualité.
3. `flutter build web --release` pour produire l’application statique.
4. Installation de Node.js + `vercel` CLI et déploiement automatique sur Vercel.

⚠️ Le job échoue si la couverture descend sous **50 %** : la commande
`dart run tool/coverage_summary.dart` est lancée après `flutter test --coverage`
avec la variable `MIN_COVERAGE=50`. Adaptez cette valeur dans le workflow si
vos besoins changent.

### Secrets à ajouter dans GitHub

Dans **Settings › Secrets and variables › Actions** du dépôt, créez :

- `VERCEL_TOKEN` : token personnel généré via `https://vercel.com/account/tokens`.
- `VERCEL_ORG_ID` : identifiant de votre organisation/compte, visible via `npx vercel org ls` ou dans le dashboard Vercel (`/settings` › *ID*).
- `VERCEL_PROJECT_ID` : identifiant du projet Vercel cible (`Project Settings › General › Project ID`).

Les secrets sont nécessaires pour la dernière étape. Sans eux, la pipeline s’arrête
après les tests/builds, ce qui permet aussi de l’exécuter pour de simples vérifications.

### Déploiement manuel depuis GitHub Actions

- Rendez-vous dans l’onglet **Actions**, choisissez le workflow *CI-CD* puis
	cliquez sur **Run workflow** pour lancer une livraison manuelle (utile après
	configuration des secrets).
- Vous pouvez suivre les logs des étapes et récupérer l’URL du déploiement via
	le job « Deploy to Vercel (production) ».
