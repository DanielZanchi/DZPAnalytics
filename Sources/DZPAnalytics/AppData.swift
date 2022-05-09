//
//  File.swift
//  
//
//  Created by Daniel Zanchi on 20/07/21.
//

import Foundation
import SwiftKeychainWrapper

extension DZPAnalytics {
    
    class AppData {
        
        enum Keys: String {
            case userDefaultsID, appVersion, keychainID, sessionCount, originalTransId, didSendReceipt
        }
        
        static let shared: AppData = AppData()
        
        var defaults: UserDefaults!
        var keychain: KeychainWrapper!
        
        private init() {
            self.defaults = UserDefaults(suiteName: "\(Bundle.main.bundleIdentifier ?? "").DZPAnalytics")
            self.keychain = KeychainWrapper(serviceName: "\(Bundle.main.bundleIdentifier ?? "").DZPAnalytics")
        }
        
        func saveData() {
            defaults.set(DZPAnalytics.AnalyticsVars.userDefaultsID, forKey: Keys.userDefaultsID.rawValue)
            
            keychain.set(DZPAnalytics.AnalyticsVars.keychainID, forKey: Keys.keychainID.rawValue)
            keychain.set(DZPAnalytics.AnalyticsVars.sessionCount, forKey: Keys.sessionCount.rawValue)
            keychain.set(DZPAnalytics.AnalyticsVars.originalTransId, forKey: Keys.originalTransId.rawValue)
            keychain.set(DZPAnalytics.AnalyticsVars.didSendReceipt, forKey: Keys.didSendReceipt.rawValue)
        }
        
        func getData() {
            if let sessionCount = keychain.integer(forKey: Keys.sessionCount.rawValue) {
                DZPAnalytics.AnalyticsVars.sessionCount = sessionCount
            }
            
            if let originalTransId = keychain.string(forKey: Keys.originalTransId.rawValue) {
                DZPAnalytics.AnalyticsVars.originalTransId = originalTransId
            }
        }
        
        func reset() {
            let domain = Bundle.main.bundleIdentifier!
            self.defaults.removePersistentDomain(forName: domain)
            self.keychain.removeAllKeys()
        }
    }
    
}
