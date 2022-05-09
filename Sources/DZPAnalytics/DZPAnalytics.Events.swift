//
//  File.swift
//  
//
//  Created by Daniel Zanchi on 21/01/22.
//

import Foundation
import SwiftyStoreKit
import FirebaseAnalytics

extension DZPAnalytics {
    
    func sendEvent(withName name: String, parameters: [String: Any]? = nil, removingDefault: Bool = false) {
        DispatchQueue(label: "DZPAnalytics.eventLogger").async {
            self.eventSemaphore.wait()
            if removingDefault {
                Analytics.setDefaultEventParameters(nil)
                Analytics.setDefaultEventParameters([
                    parametersKeys.cp_keychainID.rawValue: AnalyticsVars.keychainID,
                ])
            }
            
            Analytics.logEvent(name, parameters: parameters)
            
            if removingDefault {
                self.setDefaultParams()
            }
            self.eventSemaphore.signal()
        }
    }
    
    private func sendReceiptInfos(_ receipt: [String: AnyObject], localReceipt: Bool = false) {
        guard AnalyticsVars.didSendReceipt == false else { return }
        if let receiptInfo = receipt["receipt"] {
            if let originalPurchaseDate = receiptInfo["original_purchase_date"] as? String,
               let downloadId = receiptInfo["download_id"] as? Int,
               let originalAppVersion = receiptInfo["original_application_version"] as? String {
                sendEvent(withName: "ce_app_store_receipt", parameters: [
                    "cp_r_original_purchase_date": originalPurchaseDate,
                    "cp_r_download_id": downloadId,
                    "cp_r_original_application_version": originalAppVersion,
                    "cp_r_local_receipt": localReceipt
                ])
                
                AnalyticsVars.didSendReceipt = true
                DZPAnalytics.AppData.shared.saveData()
            }
        }
    }
    
    public func getAndSendReceipt(withSharedKey sharedKey: String, env: AppleReceiptValidator.VerifyReceiptURLType = .production, forceRefresh: Bool = false) {
        guard AnalyticsVars.didSendReceipt == false else { return }
        SwiftyStoreKit.fetchReceipt(forceRefresh: forceRefresh) { result in
            switch result {
            case .success(let receiptData):
                let validator = AppleReceiptValidator(service: env, sharedSecret: sharedKey)
                validator.validate(receiptData: receiptData) { result in
                    switch result {
                    case .success(let receipt):
                        self.sendReceiptInfos(receipt, localReceipt: !forceRefresh)
                    case .error(let error):
                        print("There was an error fetching the receipt: \(error.localizedDescription)")
                    }
                }
            case .error(let error):
                print("There was an error fetching the receipt: \(error.localizedDescription)")
            }
        }
    }
    
}
