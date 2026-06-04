//
//  Date+Extensions.swift
//  Gestfina
//
//  Extensions de Date pour le formatage
//

import Foundation

extension Date {
    
    /// Format court: "09 mai"
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L10n.dateLocaleIdentifier)
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self)
    }
    
    /// Format moyen: "09 mai 2026"
    var mediumFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L10n.dateLocaleIdentifier)
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    /// Format long: "vendredi 09 mai 2026"
    var longFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L10n.dateLocaleIdentifier)
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
    
    /// Format relatif: "Aujourd'hui", "Hier", "Il y a 3 jours"
    var relativeFormatted: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            return "Aujourd'hui"
        } else if calendar.isDateInYesterday(self) {
            return "Hier"
        } else {
            let components = calendar.dateComponents([.day], from: self, to: now)
            if let days = components.day, days < 7 {
                return "Il y a \(days) jours"
            } else {
                return shortFormatted
            }
        }
    }
    
    /// Format relatif localisé (utilise L10n)
    var localizedRelativeFormatted: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            return L10n.today
        } else if calendar.isDateInYesterday(self) {
            return L10n.yesterday
        } else {
            let components = calendar.dateComponents([.day], from: self, to: now)
            if let days = components.day, days < 7 {
                return L10n.daysAgo(days)
            } else {
                return shortFormatted
            }
        }
    }
    
    /// Heure formatée: "14:30"
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L10n.dateLocaleIdentifier)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// Nom du mois: "Mai"
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L10n.dateLocaleIdentifier)
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self).capitalized
    }
    
    /// Année: "2026"
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
}
