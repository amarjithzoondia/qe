//
//  ForgotPasswordviewModel.swift
// ALNASR
//
//  Created by developer on 21/01/22.
//

import Foundation

class ForgotPasswordViewModel: ObservableObject {
    
    @Published var isLoading = false
    var email: String = ""
    
    func resetPassword(email: String, completion: @escaping (_ completed: Bool) -> ()) {
        CommonRequest
            .forgotPassword(email: ForgotPasswordRequest.Params(email: email))
            .makeCall(responseType: ForgotPasswordRequest.Response.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                
                completion(true)
            } failure: { (error) in
                
                completion(false)
            }
    }
}
