//
//  LogInViewModel.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

class LogInViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var showToast = false
    @Published var showAlert = false
    
    
    var toast: AlertToast = Toast.alert(subTitle: "") {
        didSet {
            showToast = true
        }
    }
    
    func validateAndLogin(email: String, password: String, isGoToDashBoard: @escaping () -> Void) {
        do {
            let email = try email.validatedText(validationType: .email)
            let password = try password.validatedText(validationType: .requiredField(field: "Password".localizedString()))
            
            UserRequest
                .login(params: LoginRequest.Params(email: email, password: password))
                .makeCall(responseType: LoginRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    DispatchQueue.main.async {
                        UserManager.saveLogined(user: response.user)
                        UserManager.saveLogined(auth: response.auth)
                        UserManager.saveSettings(settings: response.settings)
                        
                        if UserManager.getCheckOutUser() != nil {
                            var checkOutUser = UserManager.getCheckOutUser()!
                            checkOutUser.isGuestUser = false
                            checkOutUser.uuid = response.user.uuid ?? ""
                            checkOutUser.userDetails = response.userDetails
                            UserManager.saveCheckOutUser(user: checkOutUser)
                            UserManager.saveUserDetails(userDetails: response.userDetails)
                            UserManager.instance.notificationUnReadCount = response.userDetails.notificationUnReadCount
                            UserManager.instance.pendingActionsCount = response.userDetails.pendingActionsCount
                        }
                        
                        if UserManager().isLogined {
                            isGoToDashBoard()
                        }
                    }
                } failure: { (error) in
                    DispatchQueue.main.async {
                        self.toast = error.toast
                    }
                }
        } catch {
            DispatchQueue.main.async {
                self.toast = (error as! SystemError).toast
            }
        }
    }
}
