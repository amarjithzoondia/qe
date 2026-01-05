//
//  SplashContentViewModel.swift
// QualityExpertise
//
//  Created by developer on 18/01/22.
//

import UIKit
import SwiftUI
import SwiftfulLoadingIndicators

class SpalshViewModel: BaseViewModel, ObservableObject {
    var uuid: String = ""
    
    //    func userCheckout(completion: @escaping (_ completed: Bool) -> ()) {
    //        self.error = nil
    //        if UserManager.getCheckOutUser()?.uuid != nil {
    //            uuid = (UserManager.getCheckOutUser()?.uuid)!
    //        } else {
    //            uuid = String(UUID().uuidString)
    //        }
    //
    //        GenericRequest
    //            .splash(SpalshRequest.Params(uuid: uuid))
    //            .makeCall(responseType: CheckOutUser.self) { (isLoading) in
    //                self.isLoading = isLoading
    //            } success: { (response) in
    //                let user = response
    ////                UserManager.instance.notificationUnReadCount = user.userDetails?.notificationUnReadCount ?? 0
    ////
    ////                UserManager.instance.pendingActionsCount = user.userDetails?.pendingActionsCount ?? 0
    //                UserManager.saveCheckOutUser(user: user)
    //                completion(true)
    //            } failure: { (error) in
    //                self.error = error
    //                self.toast = error.toast
    //            }
    //
    //    }
    
    func userCheckout(completion: @escaping (_ completed: Bool) -> ()) {
        self.error = nil
        print(LocalizationService.shared.language)
        print("--------")
        // Step 1️⃣: Get existing checkout user if available
        if let existingUser = UserManager.getCheckOutUser() {
            uuid = existingUser.uuid
        } else {
            uuid = UUID().uuidString
        }
        
        // Step 2️⃣: Check network connectivity before calling API
        if isConnectedToInternet() {
            GenericRequest
                .splash(SpalshRequest.Params(uuid: uuid))
                .makeCall(responseType: CheckOutUser.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    let user = response
                    UserManager.saveCheckOutUser(user: user)
                    completion(true)
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
            
        } else {
            print("⚠️ Offline mode detected")
            if UserManager.getCheckOutUser() != nil {
                // ✅ User available offline
                completion(true)
            } else {
                // ❌ No user saved → redirect to login
                completion(false)
            }
            return
        }
    }
    
    func isConnectedToInternet() -> Bool {
        RepositoryManager.Connectivity.isConnected
    }
    
    
}
