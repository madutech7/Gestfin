//
//  EncryptedStorageManager.swift
//  Gestfina
//
//  Service de persistance sécurisée avec chiffrement matériel iOS (Data Protection API)
//

import Foundation
import Security

class EncryptedStorageManager {
    static let shared = EncryptedStorageManager()
    
    private let fileManager = FileManager.default
    
    private init() {
        createSecureDirectoryIfNeeded()
    }
    
    /// Obtenir l'URL du dossier de stockage sécurisé
    private var secureDirectoryURL: URL {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let directory = paths[0].appendingPathComponent("SecureData", isDirectory: true)
        return directory
    }
    
    private func createSecureDirectoryIfNeeded() {
        let dir = secureDirectoryURL
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// Sauvegarder un objet de manière chiffrée avec iOS Data Protection (.completeFileProtection)
    func save<T: Encodable>(_ object: T, forKey key: String) -> Bool {
        let fileURL = secureDirectoryURL.appendingPathComponent("\(key).encrypted")
        do {
            let data = try JSONEncoder().encode(object)
            // Écriture avec protection matérielle complète (clé de chiffrement liée au mot de passe/biométrie de l'appareil)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            return true
        } catch {
            print("❌ [EncryptedStorage] Erreur de sauvegarde chiffrée pour \(key): \(error)")
            return false
        }
    }
    
    /// Charger un objet chiffré depuis le stockage sécurisé
    func load<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        let fileURL = secureDirectoryURL.appendingPathComponent("\(key).encrypted")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("❌ [EncryptedStorage] Erreur de lecture chiffrée pour \(key): \(error)")
            return nil
        }
    }
    
    /// Supprimer un fichier sécurisé
    func remove(forKey key: String) {
        let fileURL = secureDirectoryURL.appendingPathComponent("\(key).encrypted")
        try? fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Migration automatique depuis UserDefaults
    
    func migrateFromUserDefaultsIfNeeded<T: Codable>(userDefaultsKey: String, storageKey: String, type: T.Type) {
        let fileURL = secureDirectoryURL.appendingPathComponent("\(storageKey).encrypted")
        
        // Si le fichier chiffré n'existe pas encore mais que UserDefaults possède la donnée
        if !fileManager.fileExists(atPath: fileURL.path),
           let oldData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(T.self, from: oldData) {
            
            print("🔒 [EncryptedStorage] Migration sécurisée de '\(userDefaultsKey)' vers le stockage chiffré.")
            _ = save(decoded, forKey: storageKey)
            // Optionnel : effacer l'ancienne donnée en clair de UserDefaults
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
}
