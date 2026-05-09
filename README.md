# 💰 GestFina — Gestion Financière Personnelle

Application iOS de gestion financière personnelle développée en **SwiftUI** avec une interface premium sombre.

## 📱 Fonctionnalités

### 🏠 Tableau de bord
- Solde total avec animation
- Taux d'épargne en temps réel
- Revenus et dépenses rapides
- Graphique hebdomadaire des dépenses
- Répartition par catégorie
- Transactions récentes

### 💳 Transactions
- Liste complète avec recherche
- Filtres par type (revenu/dépense) et période
- Ajout de transaction avec sélection de catégorie
- Suppression par swipe ou menu contextuel

### 📊 Budgets
- Création de budgets par catégorie
- Suivi de progression avec barres visuelles
- Alertes quand un budget est dépassé
- Vue d'ensemble du budget mensuel

### 📈 Statistiques
- Répartition des dépenses par catégorie
- Répartition des revenus
- Tendance mensuelle (6 mois)
- Top catégories de dépenses

## 🎨 Design
- **Mode sombre** premium par défaut
- **Glassmorphism** et gradients modernes
- **Animations Spring** fluides
- **SF Symbols** pour toutes les icônes
- Palette de couleurs soigneusement sélectionnée

## 🛠 Architecture

```
Gestfina/
├── GestfinaApp.swift          # Point d'entrée
├── Models/
│   ├── Transaction.swift      # Modèle de transaction
│   ├── Category.swift         # Catégories avec icônes/couleurs
│   └── Budget.swift           # Modèle de budget
├── ViewModels/
│   └── FinanceViewModel.swift # Logique métier & persistance
├── Views/
│   ├── MainTabView.swift      # Navigation principale
│   ├── DashboardView.swift    # Tableau de bord
│   ├── TransactionsView.swift # Liste des transactions
│   ├── AddTransactionView.swift # Formulaire d'ajout
│   ├── BudgetView.swift       # Gestion des budgets
│   └── StatisticsView.swift   # Statistiques & graphiques
├── Components/
│   └── TransactionRow.swift   # Composant réutilisable
├── Extensions/
│   ├── Color+Extensions.swift # Thème & couleurs hex
│   └── Date+Extensions.swift  # Formatage des dates
└── Assets.xcassets/           # Ressources visuelles
```

## 🚀 Prérequis

- **macOS** avec **Xcode 15+**
- **iOS 17.0+**
- **Swift 5.9+**

## 📦 Installation

1. Ouvrez Xcode
2. `File > New > Project > iOS > App`
3. Nommez le projet **Gestfina**
4. Sélectionnez **SwiftUI** comme interface
5. Remplacez les fichiers générés par ceux de ce dossier
6. Build & Run (⌘R)

## 📝 Notes

- Les données sont persistées localement via **UserDefaults** (JSON)
- Des données d'exemple sont chargées au premier lancement
- L'app utilise uniquement des frameworks Apple natifs (pas de dépendances externes)

## 👤 Auteur

**Madu** — 2026

---

*Développé avec ❤️ en SwiftUI*
