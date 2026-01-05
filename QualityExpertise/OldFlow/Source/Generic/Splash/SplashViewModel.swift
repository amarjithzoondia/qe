//
//  SplashContentViewModel.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//

import UIKit
import SwiftUI
import SwiftfulLoadingIndicators

class SpalshViewModel: BaseViewModel, ObservableObject {
    var uuid: String = ""
    
    func userCheckout(completion: @escaping (_ completed: Bool) -> ()) {
        self.error = nil
        if UserManager.getCheckOutUser()?.uuid != nil {
            uuid = (UserManager.getCheckOutUser()?.uuid)!
        } else {
            uuid = String(UUID().uuidString)
        }
        
        GenericRequest
            .splash(SpalshRequest.Params(uuid: uuid))
            .makeCall(responseType: CheckOutUser.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                let user = response
                UserManager.instance.notificationUnReadCount = user.userDetails?.notificationUnReadCount ?? 0
                
                UserManager.instance.pendingActionsCount = user.userDetails?.pendingActionsCount ?? 0
                UserManager.saveCheckOutUser(user: user)
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }

    }
}
