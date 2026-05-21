//
//  AppFeedback.swift
//  Gestfina
//
//  Centralisation de tous les messages utilisateur (Erreurs, Succès, Alertes)
//  Style premium "SamaXaalis" - Ton professionnel et encourageant.
//

import Foundation

struct AppFeedback {
    
    // MARK: - Authentification
    struct Auth {
        static let loginFailed = "Oups ! Ces identifiants ne correspondent à aucun compte SamaXaalis."
        static let registerFailed = "Nous n'avons pas pu créer votre compte. Vérifiez vos informations."
        static let emailTaken = "Cet email est déjà lié à un compte SamaXaalis."
        static let passwordTooShort = "Votre mot de passe doit contenir au moins 8 caractères."
        static let invalidEmail = "L'adresse email saisie n'est pas valide."
        static let sessionExpired = "Votre session a expiré. Pour votre sécurité, veuillez vous reconnecter."
        static let googleAuthFailed = "La connexion avec Google a échoué. Veuillez réessayer dans un instant."
        static let logoutConfirm = "Êtes-vous sûr de vouloir vous déconnecter ?"
    }
    
    // MARK: - Transactions & Budgets
    struct Finance {
        static let transactionAdded = "Transaction enregistrée avec succès ! Votre Xaalis est à jour."
        static let transactionDeleted = "La transaction a été supprimée."
        static let budgetExceeded = "Attention ! Vous avez dépassé votre budget."
        static let missingTitle = "Veuillez donner un nom à votre transaction."
        static let zeroAmount = "Le montant de la transaction doit être supérieur à zéro."
        static let noChanges = "Aucune modification n'a été détectée."
    }
    
    // MARK: - Synchronisation & Réseau
    struct Sync {
        static let offlineMode = "Vous êtes hors-ligne. Vos données seront synchronisées dès le retour de la connexion."
        static let syncSuccess = "Synchronisation cloud réussie. Vos données sont en sécurité."
        static let syncFailed = "Impossible de synchroniser vos données avec le cloud pour le moment."
        static let networkError = "Connexion instable. Vérifiez votre réseau pour profiter de toutes les fonctionnalités."
    }
    
    // MARK: - Assistant IA
    struct AI {
        static let analysisLoading = "SamaCoach analyse vos finances... Un instant."
        static let analysisError = "SamaCoach a rencontré une petite difficulté. Réessayez plus tard."
        static let limitReached = "Vous avez atteint votre limite d'analyses pour ce mois."
    }
    
    // MARK: - Biométrie & Sécurité
    struct Security {
        static let faceIDPrompt = "Authentifiez-vous pour accéder à votre SamaXaalis."
        static let faceIDFailed = "La reconnaissance biométrique a échoué."
        static let setupRequired = "La protection biométrique n'est pas configurée sur cet appareil."
    }
    
    // MARK: - Premium
    struct Premium {
        static let featureLocked = "Cette fonctionnalité premium nécessite un abonnement."
        static let purchaseSuccess = "Bienvenue dans SamaXaalis Premium ! Profitez de toutes nos fonctionnalités."
        static let purchaseFailed = "L'achat n'a pas pu être finalisé."
    }
}
