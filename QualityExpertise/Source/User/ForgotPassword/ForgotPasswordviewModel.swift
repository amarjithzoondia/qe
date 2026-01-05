//
//  ForgotPasswordviewModel.swift
// QualityExpertise
//
//  Created by developer on 21/01/22.
//

import Foundation

class ForgotPasswordViewModel: BaseViewModel, ObservableObject {
    
    var email: String = ""
    
    func resetPassword(
        email: String,
        completion: @escaping (_ success: Bool, _ message: String?) -> ()
    ) {
        do {
            print(email)
            let validatedEmail = try email.validatedText(validationType: .email)
            CommonRequest
                .forgotPassword(email: ForgotPasswordRequest.Params(email: validatedEmail))
                .makeCall(responseType: ForgotPasswordRequest.Response.self) { isLoading in
                    self.isLoading = isLoading
                } success: { response in
                    completion(true, response.message)
                } failure: { error in
                    self.error = error
                    self.toast = error.toast
                    completion(false, error.localizedDescription)
                }
        } catch {
            self.toast = (error as! SystemError).toast
        }
    }

}
