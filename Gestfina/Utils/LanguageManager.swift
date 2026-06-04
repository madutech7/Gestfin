//
//  LanguageManager.swift
//  Gestfina
//
//  Gestionnaire de langue in-app — Changement dynamique FR / EN / WO / AR
//

import Foundation
import SwiftUI
import Combine

/// Langues supportées par l'application
enum AppLanguage: String, CaseIterable, Identifiable {
    case french   = "fr"
    case english  = "en"
    case wolof    = "wo"
    case arabic   = "ar"
    
    var id: String { rawValue }
    
    /// Nom affiché de la langue (dans la langue elle-même)
    var displayName: String {
        switch self {
        case .french:  return "Français"
        case .english: return "English"
        case .wolof:   return "Wolof"
        case .arabic:  return "العربية"
        }
    }
    
    /// Drapeau / icône emoji
    var flag: String {
        switch self {
        case .french:  return "🇫🇷"
        case .english: return "🇬🇧"
        case .wolof:   return "🇸🇳"
        case .arabic:  return "🇸🇦"
        }
    }
    
    /// Direction du texte
    var layoutDirection: LayoutDirection {
        switch self {
        case .arabic: return .rightToLeft
        default: return .leftToRight
        }
    }
}

/// Gestionnaire singleton de langue
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private let storageKey = "gestfina_app_language"
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: storageKey)
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let lang = AppLanguage(rawValue: saved) {
            currentLanguage = lang
        } else {
            // Détecter la langue du système
            let systemLang = Locale.current.language.languageCode?.identifier ?? "fr"
            currentLanguage = AppLanguage(rawValue: systemLang) ?? .french
        }
    }
}

// MARK: - L10n — Système de localisation statique

/// Accès centralisé à toutes les chaînes localisées
struct L10n {
    
    private static var lang: AppLanguage {
        LanguageManager.shared.currentLanguage
    }
    
    // MARK: - Tab Bar
    
    static var tabHome: String {
        switch lang {
        case .french:  return "Accueil"
        case .english: return "Home"
        case .wolof:   return "Kër"
        case .arabic:  return "الرئيسية"
        }
    }
    
    static var tabTransactions: String {
        switch lang {
        case .french:  return "Transactions"
        case .english: return "Transactions"
        case .wolof:   return "Raññe"
        case .arabic:  return "المعاملات"
        }
    }

    static var tabCoach: String {
        return "SamaCoach"
    }

    static var tabBudget: String {
        switch lang {
        case .french:  return "Budget"
        case .english: return "Budget"
        case .wolof:   return "Budge"
        case .arabic:  return "الميزانية"
        }
    }

    static var tabAdd: String {
        switch lang {
        case .french:  return "Ajouter"
        case .english: return "Add"
        case .wolof:   return "Yokk"
        case .arabic:  return "إضافة"
        }
    }
    
    // MARK: - Dashboard
    
    static var totalBalance: String {
        switch lang {
        case .french:  return "Solde total"
        case .english: return "Total Balance"
        case .wolof:   return "Sàldu mbooleem"
        case .arabic:  return "الرصيد الإجمالي"
        }
    }
    
    static var income: String {
        switch lang {
        case .french:  return "Revenus"
        case .english: return "Income"
        case .wolof:   return "Xaalis bu ñëw"
        case .arabic:  return "الدخل"
        }
    }
    
    static var expenses: String {
        switch lang {
        case .french:  return "Dépenses"
        case .english: return "Expenses"
        case .wolof:   return "Depaans"
        case .arabic:  return "المصروفات"
        }
    }
    
    static var activity: String {
        switch lang {
        case .french:  return "Activité"
        case .english: return "Activity"
        case .wolof:   return "Liggéey"
        case .arabic:  return "النشاط"
        }
    }
    
    static var sevenDays: String {
        switch lang {
        case .french:  return "7 jours"
        case .english: return "7 days"
        case .wolof:   return "7 fan"
        case .arabic:  return "7 أيام"
        }
    }
    
    static var categories: String {
        switch lang {
        case .french:  return "catégories"
        case .english: return "categories"
        case .wolof:   return "xeet"
        case .arabic:  return "فئات"
        }
    }
    
    static var recent: String {
        switch lang {
        case .french:  return "Récentes"
        case .english: return "Recent"
        case .wolof:   return "Yéésal"
        case .arabic:  return "الأخيرة"
        }
    }
    
    static var noTransaction: String {
        switch lang {
        case .french:  return "Aucune transaction"
        case .english: return "No transactions"
        case .wolof:   return "Amul raññe"
        case .arabic:  return "لا توجد معاملات"
        }
    }
    
    static var addFirstTransaction: String {
        switch lang {
        case .french:  return "Ajoutez votre première opération"
        case .english: return "Add your first transaction"
        case .wolof:   return "Yokk sa njëkk raññe"
        case .arabic:  return "أضف أول معاملة لك"
        }
    }
    
    static var edit: String {
        switch lang {
        case .french:  return "Modifier"
        case .english: return "Edit"
        case .wolof:   return "Soppi"
        case .arabic:  return "تعديل"
        }
    }
    
    static var delete: String {
        switch lang {
        case .french:  return "Supprimer"
        case .english: return "Delete"
        case .wolof:   return "Far"
        case .arabic:  return "حذف"
        }
    }
    
    static var deleteTransactionConfirm: String {
        switch lang {
        case .french:  return "Supprimer cette transaction ?"
        case .english: return "Delete this transaction?"
        case .wolof:   return "Bëgg nga far raññe bi?"
        case .arabic:  return "هل تريد حذف هذه المعاملة؟"
        }
    }
    
    static func willBeDeleted(_ title: String) -> String {
        switch lang {
        case .french:  return "« \(title) » sera définitivement supprimée."
        case .english: return "\"\(title)\" will be permanently deleted."
        case .wolof:   return "« \(title) » dina far ci lu mujj."
        case .arabic:  return "سيتم حذف \"\(title)\" نهائياً."
        }
    }
    
    static var cancel: String {
        switch lang {
        case .french:  return "Annuler"
        case .english: return "Cancel"
        case .wolof:   return "Nàkk"
        case .arabic:  return "إلغاء"
        }
    }
    
    static var offline: String {
        switch lang {
        case .french:  return "Hors-ligne"
        case .english: return "Offline"
        case .wolof:   return "Ci biir"
        case .arabic:  return "غير متصل"
        }
    }
    
    static var pending: String {
        switch lang {
        case .french:  return "en attente"
        case .english: return "pending"
        case .wolof:   return "xaar na"
        case .arabic:  return "قيد الانتظار"
        }
    }
    
    // MARK: - Settings
    
    static var settings: String {
        switch lang {
        case .french:  return "Réglages"
        case .english: return "Settings"
        case .wolof:   return "Teral"
        case .arabic:  return "الإعدادات"
        }
    }
    
    static var subscription: String {
        switch lang {
        case .french:  return "Mon abonnement"
        case .english: return "My Subscription"
        case .wolof:   return "Sama abonman"
        case .arabic:  return "اشتراكي"
        }
    }
    
    static var activeSubscription: String {
        switch lang {
        case .french:  return "Abonnement actif — Merci pour votre soutien !"
        case .english: return "Active subscription — Thank you for your support!"
        case .wolof:   return "Abonman bi dafa am — Jërëjëf ci sa ndimbal!"
        case .arabic:  return "اشتراك فعال — شكراً لدعمك!"
        }
    }
    
    static var unlockPremium: String {
        switch lang {
        case .french:  return "Débloquez les transactions illimitées & stats"
        case .english: return "Unlock unlimited transactions & stats"
        case .wolof:   return "Ubbi raññe yu ñaari ak stats"
        case .arabic:  return "فتح المعاملات غير المحدودة والإحصائيات"
        }
    }
    
    static var active: String {
        switch lang {
        case .french:  return "Actif"
        case .english: return "Active"
        case .wolof:   return "Dafa dox"
        case .arabic:  return "فعال"
        }
    }
    
    static var profile: String {
        switch lang {
        case .french:  return "Profil"
        case .english: return "Profile"
        case .wolof:   return "Profil"
        case .arabic:  return "الملف الشخصي"
        }
    }
    
    static var tapToEdit: String {
        switch lang {
        case .french:  return "Appuyer pour modifier"
        case .english: return "Tap to edit"
        case .wolof:   return "Bës ngir soppi"
        case .arabic:  return "انقر للتعديل"
        }
    }
    
    static var currency: String {
        switch lang {
        case .french:  return "Devise"
        case .english: return "Currency"
        case .wolof:   return "Xaalis"
        case .arabic:  return "العملة"
        }
    }
    
    static var currencyFooter: String {
        switch lang {
        case .french:  return "La devise sélectionnée sera utilisée pour toutes les transactions et les budgets."
        case .english: return "The selected currency will be used for all transactions and budgets."
        case .wolof:   return "Xaalis bi nga tànn dina jëfandikoo ci raññe yi ak budge yi."
        case .arabic:  return "سيتم استخدام العملة المختارة لجميع المعاملات والميزانيات."
        }
    }
    
    static var display: String {
        switch lang {
        case .french:  return "Affichage"
        case .english: return "Display"
        case .wolof:   return "Wone"
        case .arabic:  return "العرض"
        }
    }
    
    static var appearance: String {
        switch lang {
        case .french:  return "Apparence"
        case .english: return "Appearance"
        case .wolof:   return "Mel"
        case .arabic:  return "المظهر"
        }
    }
    
    static var systemTheme: String {
        switch lang {
        case .french:  return "Système"
        case .english: return "System"
        case .wolof:   return "Sisteem"
        case .arabic:  return "النظام"
        }
    }
    
    static var lightTheme: String {
        switch lang {
        case .french:  return "Clair"
        case .english: return "Light"
        case .wolof:   return "Leer"
        case .arabic:  return "فاتح"
        }
    }
    
    static var darkTheme: String {
        switch lang {
        case .french:  return "Sombre"
        case .english: return "Dark"
        case .wolof:   return "Lëndëm"
        case .arabic:  return "داكن"
        }
    }
    
    static var language: String {
        switch lang {
        case .french:  return "Langue"
        case .english: return "Language"
        case .wolof:   return "Làkk"
        case .arabic:  return "اللغة"
        }
    }
    
    static var languageSection: String {
        switch lang {
        case .french:  return "Langue de l'application"
        case .english: return "App Language"
        case .wolof:   return "Làkk bi ci jëfandiku"
        case .arabic:  return "لغة التطبيق"
        }
    }
    
    static var security: String {
        switch lang {
        case .french:  return "Sécurité"
        case .english: return "Security"
        case .wolof:   return "Aar"
        case .arabic:  return "الأمان"
        }
    }
    
    static func securityFooterEnabled(_ biometricName: String) -> String {
        switch lang {
        case .french:  return "L'application se verrouille automatiquement en arrière-plan."
        case .english: return "The app locks automatically in the background."
        case .wolof:   return "App bi dafa tëj boppam ci jalgati."
        case .arabic:  return "يتم قفل التطبيق تلقائياً في الخلفية."
        }
    }
    
    static func securityFooterDisabled(_ biometricName: String) -> String {
        switch lang {
        case .french:  return "Activez \(biometricName) pour protéger vos données financières."
        case .english: return "Enable \(biometricName) to protect your financial data."
        case .wolof:   return "Teral \(biometricName) ngir aar sa xaalis yi."
        case .arabic:  return "تفعيل \(biometricName) لحماية بياناتك المالية."
        }
    }
    
    static var biometricUnavailable: String {
        switch lang {
        case .french:  return "Biométrie non disponible"
        case .english: return "Biometrics unavailable"
        case .wolof:   return "Biometri amul"
        case .arabic:  return "القياسات الحيوية غير متاحة"
        }
    }
    
    static var encryptedStorage: String {
        switch lang {
        case .french:  return "Stockage chiffré local"
        case .english: return "Encrypted local storage"
        case .wolof:   return "Duukaasu ci biir"
        case .arabic:  return "تخزين محلي مشفر"
        }
    }
    
    static var notifications: String {
        switch lang {
        case .french:  return "Notifications"
        case .english: return "Notifications"
        case .wolof:   return "Yëgal"
        case .arabic:  return "الإشعارات"
        }
    }
    
    static var enableNotifications: String {
        switch lang {
        case .french:  return "Activer les notifications"
        case .english: return "Enable notifications"
        case .wolof:   return "Teral yëgal yi"
        case .arabic:  return "تفعيل الإشعارات"
        }
    }
    
    static var openSystemSettings: String {
        switch lang {
        case .french:  return "Ouvrir les Réglages système"
        case .english: return "Open System Settings"
        case .wolof:   return "Ubbi teral yi"
        case .arabic:  return "فتح إعدادات النظام"
        }
    }
    
    static var notifDenied: String {
        switch lang {
        case .french:  return "Notifications désactivées. Activez-les dans Réglages > SamaXaalis."
        case .english: return "Notifications disabled. Enable them in Settings > SamaXaalis."
        case .wolof:   return "Yëgal yi tëj nañu. Ubbi ko ci Teral > SamaXaalis."
        case .arabic:  return "الإشعارات معطلة. قم بتفعيلها من الإعدادات > SamaXaalis."
        }
    }
    
    static var budgetAlerts: String {
        switch lang {
        case .french:  return "Alertes budget"
        case .english: return "Budget alerts"
        case .wolof:   return "Yëgal budge"
        case .arabic:  return "تنبيهات الميزانية"
        }
    }
    
    static var budgetAlertSubtitle: String {
        switch lang {
        case .french:  return "Quand 80% ou 100% est atteint"
        case .english: return "When 80% or 100% is reached"
        case .wolof:   return "Bu 80% walla 100% féete"
        case .arabic:  return "عند الوصول إلى 80% أو 100%"
        }
    }
    
    static var dailyReminder: String {
        switch lang {
        case .french:  return "Rappel quotidien"
        case .english: return "Daily reminder"
        case .wolof:   return "Fàttaliku bés bu nekk"
        case .arabic:  return "تذكير يومي"
        }
    }
    
    static var dailyReminderSubtitle: String {
        switch lang {
        case .french:  return "Saisir vos dépenses du jour"
        case .english: return "Log your daily expenses"
        case .wolof:   return "Bind sa depaans yu tey"
        case .arabic:  return "سجل مصروفاتك اليومية"
        }
    }
    
    static var reminderTime: String {
        switch lang {
        case .french:  return "Heure du rappel"
        case .english: return "Reminder time"
        case .wolof:   return "Waxtu fàttaliku"
        case .arabic:  return "وقت التذكير"
        }
    }
    
    static var data: String {
        switch lang {
        case .french:  return "Données"
        case .english: return "Data"
        case .wolof:   return "Njoxe"
        case .arabic:  return "البيانات"
        }
    }
    
    static var savedTransactions: String {
        switch lang {
        case .french:  return "Transactions enregistrées"
        case .english: return "Saved transactions"
        case .wolof:   return "Raññe yi denc nañu"
        case .arabic:  return "المعاملات المحفوظة"
        }
    }
    
    static var activeBudgets: String {
        switch lang {
        case .french:  return "Budgets actifs"
        case .english: return "Active budgets"
        case .wolof:   return "Budge yu am doole"
        case .arabic:  return "الميزانيات النشطة"
        }
    }
    
    static var logout: String {
        switch lang {
        case .french:  return "Se déconnecter"
        case .english: return "Log out"
        case .wolof:   return "Génn"
        case .arabic:  return "تسجيل الخروج"
        }
    }
    
    static var resetDevice: String {
        switch lang {
        case .french:  return "Réinitialiser l'appareil"
        case .english: return "Reset device"
        case .wolof:   return "Tàmbali"
        case .arabic:  return "إعادة تعيين الجهاز"
        }
    }
    
    static var resetConfirm: String {
        switch lang {
        case .french:  return "Réinitialiser SamaXaalis ?"
        case .english: return "Reset SamaXaalis?"
        case .wolof:   return "Tàmbali SamaXaalis?"
        case .arabic:  return "إعادة تعيين SamaXaalis؟"
        }
    }
    
    static var deleteAll: String {
        switch lang {
        case .french:  return "Tout effacer"
        case .english: return "Delete all"
        case .wolof:   return "Far lépp"
        case .arabic:  return "حذف الكل"
        }
    }
    
    static var resetMessage: String {
        switch lang {
        case .french:  return "Toutes vos transactions et budgets locaux seront supprimés. Cette action est irréversible."
        case .english: return "All your local transactions and budgets will be deleted. This action is irreversible."
        case .wolof:   return "Sa raññe yi ak budge yi lépp dina ñu far. Jëf jii duñu ko dellu."
        case .arabic:  return "سيتم حذف جميع المعاملات والميزانيات المحلية. لا يمكن التراجع عن هذا الإجراء."
        }
    }
    
    static var dataFooter: String {
        switch lang {
        case .french:  return "Vos données sont stockées localement et synchronisées de manière sécurisée sur votre compte SamaXaalis Cloud."
        case .english: return "Your data is stored locally and securely synced to your SamaXaalis Cloud account."
        case .wolof:   return "Sa njoxe yi dañu ñu denc ci sa telefon te sync ci SamaXaalis Cloud."
        case .arabic:  return "يتم تخزين بياناتك محلياً ومزامنتها بأمان مع حساب SamaXaalis Cloud."
        }
    }
    
    static var about: String {
        switch lang {
        case .french:  return "À propos"
        case .english: return "About"
        case .wolof:   return "Ci kaw"
        case .arabic:  return "حول"
        }
    }
    
    static var version: String { "Version" }
    
    static var developer: String {
        switch lang {
        case .french:  return "Développeur"
        case .english: return "Developer"
        case .wolof:   return "Jotukaay"
        case .arabic:  return "المطور"
        }
    }
    
    static var localData: String {
        switch lang {
        case .french:  return "Données 100% locales"
        case .english: return "100% local data"
        case .wolof:   return "Njoxe 100% ci biir"
        case .arabic:  return "بيانات محلية 100%"
        }
    }
    
    static var privacyPolicy: String {
        switch lang {
        case .french:  return "Politique de confidentialité"
        case .english: return "Privacy Policy"
        case .wolof:   return "Sàqub sutura"
        case .arabic:  return "سياسة الخصوصية"
        }
    }
    
    static var termsOfUse: String {
        switch lang {
        case .french:  return "Conditions d'utilisation (EULA)"
        case .english: return "Terms of Use (EULA)"
        case .wolof:   return "Sàrt yi"
        case .arabic:  return "شروط الاستخدام (EULA)"
        }
    }
    
    static var editProfile: String {
        switch lang {
        case .french:  return "Modifier le profil"
        case .english: return "Edit Profile"
        case .wolof:   return "Soppi profil"
        case .arabic:  return "تعديل الملف الشخصي"
        }
    }
    
    static var yourName: String {
        switch lang {
        case .french:  return "Votre prénom"
        case .english: return "Your first name"
        case .wolof:   return "Sa tur"
        case .arabic:  return "اسمك الأول"
        }
    }
    
    static var firstName: String {
        switch lang {
        case .french:  return "Prénom"
        case .english: return "First name"
        case .wolof:   return "Tur"
        case .arabic:  return "الاسم"
        }
    }
    
    static var save: String {
        switch lang {
        case .french:  return "Enregistrer"
        case .english: return "Save"
        case .wolof:   return "Denc"
        case .arabic:  return "حفظ"
        }
    }
    
    static var searchCurrency: String {
        switch lang {
        case .french:  return "Rechercher une devise"
        case .english: return "Search currency"
        case .wolof:   return "Wut xaalis"
        case .arabic:  return "البحث عن عملة"
        }
    }
    
    static var chooseCurrency: String {
        switch lang {
        case .french:  return "Choisir une devise"
        case .english: return "Choose currency"
        case .wolof:   return "Tànn xaalis"
        case .arabic:  return "اختيار العملة"
        }
    }
    
    // MARK: - Add / Edit Transaction
    
    static var amount: String {
        switch lang {
        case .french:  return "Montant"
        case .english: return "Amount"
        case .wolof:   return "Jëmu"
        case .arabic:  return "المبلغ"
        }
    }
    
    static var transactionTitle: String {
        switch lang {
        case .french:  return "Titre de la transaction"
        case .english: return "Transaction title"
        case .wolof:   return "Sañ-sañu raññe bi"
        case .arabic:  return "عنوان المعاملة"
        }
    }
    
    static var noteOptional: String {
        switch lang {
        case .french:  return "Note (optionnel)"
        case .english: return "Note (optional)"
        case .wolof:   return "Binde (su bëggee)"
        case .arabic:  return "ملاحظة (اختياري)"
        }
    }
    
    static var recurringTransaction: String {
        switch lang {
        case .french:  return "Transaction récurrente"
        case .english: return "Recurring transaction"
        case .wolof:   return "Raññe bu déllu"
        case .arabic:  return "معاملة متكررة"
        }
    }
    
    static var frequency: String {
        switch lang {
        case .french:  return "Fréquence"
        case .english: return "Frequency"
        case .wolof:   return "Ñaari"
        case .arabic:  return "التكرار"
        }
    }
    
    static var information: String {
        switch lang {
        case .french:  return "Informations"
        case .english: return "Information"
        case .wolof:   return "Xibaar"
        case .arabic:  return "المعلومات"
        }
    }
    
    static var category: String {
        switch lang {
        case .french:  return "Catégorie"
        case .english: return "Category"
        case .wolof:   return "Xeet"
        case .arabic:  return "الفئة"
        }
    }
    
    static var newTransaction: String {
        switch lang {
        case .french:  return "Nouvelle transaction"
        case .english: return "New Transaction"
        case .wolof:   return "Raññe bu bees"
        case .arabic:  return "معاملة جديدة"
        }
    }
    
    static var addButton: String {
        switch lang {
        case .french:  return "Ajouter"
        case .english: return "Add"
        case .wolof:   return "Yokk"
        case .arabic:  return "إضافة"
        }
    }
    
    static var editTransaction: String {
        switch lang {
        case .french:  return "Modifier"
        case .english: return "Edit"
        case .wolof:   return "Soppi"
        case .arabic:  return "تعديل"
        }
    }
    
    static var deleteThisTransaction: String {
        switch lang {
        case .french:  return "Supprimer cette transaction"
        case .english: return "Delete this transaction"
        case .wolof:   return "Far raññe bii"
        case .arabic:  return "حذف هذه المعاملة"
        }
    }
    
    // MARK: - Transactions List
    
    static var searchTransaction: String {
        switch lang {
        case .french:  return "Rechercher une transaction"
        case .english: return "Search transactions"
        case .wolof:   return "Wut raññe"
        case .arabic:  return "البحث عن معاملة"
        }
    }
    
    static var all: String {
        switch lang {
        case .french:  return "Tout"
        case .english: return "All"
        case .wolof:   return "Lépp"
        case .arabic:  return "الكل"
        }
    }
    
    static func operationsCount(_ count: Int) -> String {
        switch lang {
        case .french:  return "\(count) opérations"
        case .english: return "\(count) operations"
        case .wolof:   return "\(count) jëf"
        case .arabic:  return "\(count) عمليات"
        }
    }
    
    static var addFirstViaPlus: String {
        switch lang {
        case .french:  return "Ajoutez votre première opération\nvia le bouton +"
        case .english: return "Add your first transaction\nusing the + button"
        case .wolof:   return "Yokk sa njëkk raññe\nci jokkere +"
        case .arabic:  return "أضف أول معاملة لك\nباستخدام زر +"
        }
    }
    
    static var exportCSV: String {
        switch lang {
        case .french:  return "Exporter en CSV"
        case .english: return "Export as CSV"
        case .wolof:   return "Yóbbu CSV"
        case .arabic:  return "تصدير CSV"
        }
    }
    
    static var exportPDF: String {
        switch lang {
        case .french:  return "Exporter en PDF"
        case .english: return "Export as PDF"
        case .wolof:   return "Yóbbu PDF"
        case .arabic:  return "تصدير PDF"
        }
    }
    
    static var export: String {
        switch lang {
        case .french:  return "Exporter"
        case .english: return "Export"
        case .wolof:   return "Yóbbu"
        case .arabic:  return "تصدير"
        }
    }
    
    // MARK: - Budget
    
    static var budgets: String {
        switch lang {
        case .french:  return "Budgets"
        case .english: return "Budgets"
        case .wolof:   return "Budge"
        case .arabic:  return "الميزانيات"
        }
    }
    
    static var myBudgets: String {
        switch lang {
        case .french:  return "Mes budgets"
        case .english: return "My Budgets"
        case .wolof:   return "Samay budge"
        case .arabic:  return "ميزانياتي"
        }
    }
    
    static var noBudget: String {
        switch lang {
        case .french:  return "Aucun budget défini"
        case .english: return "No budgets defined"
        case .wolof:   return "Amul budge"
        case .arabic:  return "لا توجد ميزانيات"
        }
    }
    
    static var createFirstBudget: String {
        switch lang {
        case .french:  return "Créez votre premier budget pour suivre vos dépenses de manière intelligente."
        case .english: return "Create your first budget to track your expenses intelligently."
        case .wolof:   return "Sos sa njëkk budge ngir topp sa depaans."
        case .arabic:  return "أنشئ ميزانيتك الأولى لتتبع مصروفاتك بذكاء."
        }
    }
    
    static var used: String {
        switch lang {
        case .french:  return "utilisé"
        case .english: return "used"
        case .wolof:   return "jëfandikoo"
        case .arabic:  return "مستخدم"
        }
    }
    
    static var globalBudget: String {
        switch lang {
        case .french:  return "Budget global"
        case .english: return "Global Budget"
        case .wolof:   return "Budge mbooleem"
        case .arabic:  return "الميزانية الإجمالية"
        }
    }
    
    static var spent: String {
        switch lang {
        case .french:  return "Dépensé"
        case .english: return "Spent"
        case .wolof:   return "Dépensé"
        case .arabic:  return "المصروف"
        }
    }
    
    static var remaining: String {
        switch lang {
        case .french:  return "Restant"
        case .english: return "Remaining"
        case .wolof:   return "Desu"
        case .arabic:  return "المتبقي"
        }
    }
    
    static func usedPercent(_ pct: Int) -> String {
        switch lang {
        case .french:  return "\(pct)% utilisé"
        case .english: return "\(pct)% used"
        case .wolof:   return "\(pct)% jëfandikoo"
        case .arabic:  return "\(pct)% مستخدم"
        }
    }
    
    static func remainsAmount(_ formatted: String) -> String {
        switch lang {
        case .french:  return "Reste \(formatted)"
        case .english: return "Remains \(formatted)"
        case .wolof:   return "Desu \(formatted)"
        case .arabic:  return "المتبقي \(formatted)"
        }
    }
    
    static func ofLimit(_ limit: String) -> String {
        switch lang {
        case .french:  return "sur \(limit)"
        case .english: return "of \(limit)"
        case .wolof:   return "ci \(limit)"
        case .arabic:  return "من \(limit)"
        }
    }
    
    static var spendingLimit: String {
        switch lang {
        case .french:  return "Limite de dépense"
        case .english: return "Spending limit"
        case .wolof:   return "Caabi depaans"
        case .arabic:  return "حد الإنفاق"
        }
    }
    
    static var period: String {
        switch lang {
        case .french:  return "Période"
        case .english: return "Period"
        case .wolof:   return "Diiru"
        case .arabic:  return "الفترة"
        }
    }
    
    static var newBudget: String {
        switch lang {
        case .french:  return "Nouveau budget"
        case .english: return "New Budget"
        case .wolof:   return "Budge bu bees"
        case .arabic:  return "ميزانية جديدة"
        }
    }
    
    static var editBudget: String {
        switch lang {
        case .french:  return "Modifier le budget"
        case .english: return "Edit Budget"
        case .wolof:   return "Soppi budge bi"
        case .arabic:  return "تعديل الميزانية"
        }
    }
    
    static var done: String {
        switch lang {
        case .french:  return "Terminé"
        case .english: return "Done"
        case .wolof:   return "Jeex na"
        case .arabic:  return "تم"
        }
    }
    
    // MARK: - Coach / AI
    
    static var askCoach: String {
        switch lang {
        case .french:  return "Demandez à SamaCoach..."
        case .english: return "Ask SamaCoach..."
        case .wolof:   return "Laaj SamaCoach..."
        case .arabic:  return "اسأل SamaCoach..."
        }
    }
    
    static var editQuestion: String {
        switch lang {
        case .french:  return "Modifier la question"
        case .english: return "Edit question"
        case .wolof:   return "Soppi laaj bi"
        case .arabic:  return "تعديل السؤال"
        }
    }
    
    static var coachSuggestion1: String {
        switch lang {
        case .french:  return "Comment optimiser mes économies ?"
        case .english: return "How to optimize my savings?"
        case .wolof:   return "Naka laa mëna aar sama xaalis?"
        case .arabic:  return "كيف أحسن مدخراتي؟"
        }
    }
    
    static var coachSuggestion2: String {
        switch lang {
        case .french:  return "Réduire le budget alimentation"
        case .english: return "Reduce the food budget"
        case .wolof:   return "Wàññi budge lekk"
        case .arabic:  return "تقليل ميزانية الطعام"
        }
    }
    
    static var coachSuggestion3: String {
        switch lang {
        case .french:  return "Analyser un projet d'achat"
        case .english: return "Analyze a purchase project"
        case .wolof:   return "Seetlu jëkk bu bees"
        case .arabic:  return "تحليل مشروع شراء"
        }
    }
    
    // MARK: - Lock Screen
    
    static var isLocked: String {
        switch lang {
        case .french:  return "est verrouillé"
        case .english: return "is locked"
        case .wolof:   return "tëj na"
        case .arabic:  return "مقفل"
        }
    }
    
    static func useBiometric(_ name: String) -> String {
        switch lang {
        case .french:  return "Utiliser \(name)"
        case .english: return "Use \(name)"
        case .wolof:   return "Jëfandikoo \(name)"
        case .arabic:  return "استخدام \(name)"
        }
    }
    
    // MARK: - Onboarding
    
    static var welcomeTitle: String {
        switch lang {
        case .french:  return "Bienvenue sur SamaXaalis"
        case .english: return "Welcome to SamaXaalis"
        case .wolof:   return "Dalal jàmm ci SamaXaalis"
        case .arabic:  return "مرحباً في SamaXaalis"
        }
    }
    
    static var welcomeDesc: String {
        switch lang {
        case .french:  return "La façon la plus simple et élégante de gérer votre portefeuille et vos finances personnelles au quotidien."
        case .english: return "The simplest and most elegant way to manage your wallet and personal finances daily."
        case .wolof:   return "Yoon bi gëna sedd ngir saytu sa xaalis bés bu nekk."
        case .arabic:  return "الطريقة الأبسط والأكثر أناقة لإدارة محفظتك وأموالك الشخصية يومياً."
        }
    }
    
    static var trackTitle: String {
        switch lang {
        case .french:  return "Suivez vos dépenses"
        case .english: return "Track your expenses"
        case .wolof:   return "Topp say depaans"
        case .arabic:  return "تتبع مصروفاتك"
        }
    }
    
    static var trackDesc: String {
        switch lang {
        case .french:  return "Obtenez des statistiques claires, fluides et précises sur vos habitudes de consommation."
        case .english: return "Get clear, smooth and accurate statistics on your spending habits."
        case .wolof:   return "Am stats yu leer ci sa jëfandikoo xaalis."
        case .arabic:  return "احصل على إحصائيات واضحة ودقيقة عن عادات الإنفاق."
        }
    }
    
    static var securityTitle: String {
        switch lang {
        case .french:  return "Sécurité absolue"
        case .english: return "Absolute Security"
        case .wolof:   return "Aar bu mat"
        case .arabic:  return "أمان مطلق"
        }
    }
    
    static var securityDesc: String {
        switch lang {
        case .french:  return "Vos données sont protégées par Face ID et chiffrées en toute sécurité sur votre appareil."
        case .english: return "Your data is protected by Face ID and securely encrypted on your device."
        case .wolof:   return "Say njoxe dañu ñu aar ak Face ID te dañu ñu denc ci aar."
        case .arabic:  return "بياناتك محمية بـ Face ID ومشفرة بأمان على جهازك."
        }
    }
    
    static var skip: String {
        switch lang {
        case .french:  return "Ignorer"
        case .english: return "Skip"
        case .wolof:   return "Jël"
        case .arabic:  return "تخطي"
        }
    }
    
    static var start: String {
        switch lang {
        case .french:  return "Commencer"
        case .english: return "Get Started"
        case .wolof:   return "Tàmbali"
        case .arabic:  return "ابدأ"
        }
    }
    
    static var continueButton: String {
        switch lang {
        case .french:  return "Continuer"
        case .english: return "Continue"
        case .wolof:   return "Jokk"
        case .arabic:  return "متابعة"
        }
    }
    
    // MARK: - Transaction Row
    
    static var incomeType: String {
        switch lang {
        case .french:  return "Revenu"
        case .english: return "Income"
        case .wolof:   return "Xaalis bu ñëw"
        case .arabic:  return "دخل"
        }
    }
    
    static var expenseType: String {
        switch lang {
        case .french:  return "Dépense"
        case .english: return "Expense"
        case .wolof:   return "Depaans"
        case .arabic:  return "مصروف"
        }
    }
    
    static var copyAmount: String {
        switch lang {
        case .french:  return "Copier le montant"
        case .english: return "Copy amount"
        case .wolof:   return "Natt jëmu bi"
        case .arabic:  return "نسخ المبلغ"
        }
    }
    
    static var copyTitle: String {
        switch lang {
        case .french:  return "Copier le titre"
        case .english: return "Copy title"
        case .wolof:   return "Natt sañ-sañ bi"
        case .arabic:  return "نسخ العنوان"
        }
    }
    
    // MARK: - Date Extensions
    
    static var today: String {
        switch lang {
        case .french:  return "Aujourd'hui"
        case .english: return "Today"
        case .wolof:   return "Tey"
        case .arabic:  return "اليوم"
        }
    }
    
    static var yesterday: String {
        switch lang {
        case .french:  return "Hier"
        case .english: return "Yesterday"
        case .wolof:   return "Démb"
        case .arabic:  return "أمس"
        }
    }
    
    static func daysAgo(_ n: Int) -> String {
        switch lang {
        case .french:  return "Il y a \(n) jours"
        case .english: return "\(n) days ago"
        case .wolof:   return "\(n) fan ci ginaaw"
        case .arabic:  return "منذ \(n) أيام"
        }
    }
    
    // MARK: - Category Names
    
    static func categoryName(_ cat: TransactionCategory) -> String {
        switch lang {
        case .french:
            return cat.rawValue // Already French
        case .english:
            switch cat {
            case .salary:        return "Salary"
            case .freelance:     return "Freelance"
            case .investment:    return "Investment"
            case .food:          return "Food"
            case .housing:       return "Housing"
            case .transport:     return "Transport"
            case .utilities:     return "Bills"
            case .entertainment: return "Entertainment"
            case .shopping:      return "Shopping"
            case .health:        return "Health"
            case .education:     return "Education"
            case .savings:       return "Savings"
            case .other:         return "Other"
            }
        case .wolof:
            switch cat {
            case .salary:        return "Fey"
            case .freelance:     return "Freelance"
            case .investment:    return "Investisman"
            case .food:          return "Lekk"
            case .housing:       return "Nëg"
            case .transport:     return "Yoon"
            case .utilities:     return "Faktiir"
            case .entertainment: return "Neex"
            case .shopping:      return "Jënd"
            case .health:        return "Wergu yaram"
            case .education:     return "Jàng"
            case .savings:       return "Aar"
            case .other:         return "Yeneen"
            }
        case .arabic:
            switch cat {
            case .salary:        return "الراتب"
            case .freelance:     return "عمل حر"
            case .investment:    return "استثمار"
            case .food:          return "طعام"
            case .housing:       return "سكن"
            case .transport:     return "نقل"
            case .utilities:     return "فواتير"
            case .entertainment: return "ترفيه"
            case .shopping:      return "تسوق"
            case .health:        return "صحة"
            case .education:     return "تعليم"
            case .savings:       return "ادخار"
            case .other:         return "أخرى"
            }
        }
    }
    
    // MARK: - TimePeriod
    
    static func periodName(_ period: FinanceViewModel.TimePeriod) -> String {
        switch lang {
        case .french:
            return period.rawValue
        case .english:
            switch period {
            case .week:  return "Week"
            case .month: return "Month"
            case .year:  return "Year"
            case .all:   return "All"
            }
        case .wolof:
            switch period {
            case .week:  return "Ayu-bis"
            case .month: return "Weer"
            case .year:  return "At"
            case .all:   return "Lépp"
            }
        case .arabic:
            switch period {
            case .week:  return "أسبوع"
            case .month: return "شهر"
            case .year:  return "سنة"
            case .all:   return "الكل"
            }
        }
    }
    
    // MARK: - RecurringFrequency
    
    static func frequencyName(_ freq: RecurringFrequency) -> String {
        switch lang {
        case .french:
            return freq.rawValue
        case .english:
            switch freq {
            case .daily:   return "Daily"
            case .weekly:  return "Weekly"
            case .monthly: return "Monthly"
            case .yearly:  return "Yearly"
            }
        case .wolof:
            switch freq {
            case .daily:   return "Bés bu nekk"
            case .weekly:  return "Ayu-bis"
            case .monthly: return "Weer wu nekk"
            case .yearly:  return "At wu nekk"
            }
        case .arabic:
            switch freq {
            case .daily:   return "يومي"
            case .weekly:  return "أسبوعي"
            case .monthly: return "شهري"
            case .yearly:  return "سنوي"
            }
        }
    }
    
    // MARK: - BudgetPeriod
    
    static func budgetPeriodName(_ period: BudgetPeriod) -> String {
        switch lang {
        case .french:
            return period.rawValue
        case .english:
            switch period {
            case .weekly:  return "Weekly"
            case .monthly: return "Monthly"
            case .yearly:  return "Yearly"
            }
        case .wolof:
            switch period {
            case .weekly:  return "Ayu-bis"
            case .monthly: return "Weer"
            case .yearly:  return "At"
            }
        case .arabic:
            switch period {
            case .weekly:  return "أسبوعي"
            case .monthly: return "شهري"
            case .yearly:  return "سنوي"
            }
        }
    }
    
    // MARK: - Date Locale
    
    static var dateLocaleIdentifier: String {
        switch lang {
        case .french:  return "fr_FR"
        case .english: return "en_US"
        case .wolof:   return "fr_SN"
        case .arabic:  return "ar_SA"
        }
    }
}
