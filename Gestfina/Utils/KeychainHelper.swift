//
//  KeychainHelper.swift
//  Gestfina
//
//  Helper pour le stockage s\u{00E9}curis\u{00E9} (Keychain) — JWT Tokens
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as [String: Any]
        
        // Supprimer l'existant s'il y en a un
        SecItemDelete(query as CFDictionary)
        
        // Ajouter le nouveau
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("❌ [Keychain] Erreur lors de la sauvegarde: \(status)")
        }
    }
    
    func save(string: String, service: String, account: String) {
        if let data = string.data(using: .utf8) {
            save(data, service: service, account: account)
        }
    }
    
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as [String: Any]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        return result as? Data
    }
    
    func readString(service: String, account: String) -> String? {
        if let data = read(service: service, account: account) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
    }
}
