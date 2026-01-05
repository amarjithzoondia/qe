//
//  OTPVerificationViewModel.swift
// QualityExpertise
//
//  Created by developer on 20/01/22.
//

import SwiftUI

class OTPVerificationViewModel: BaseViewModel, ObservableObject {
    
    @Published var email: String = ""
    @Published var tempUserId: Int = -1
    var resendBalanceDuration: Double
    
    init(email: String, tempUserId: Int, resendBalanceDuration: Double) {
        self.email = email
        self.tempUserId = tempUserId
        self.resendBalanceDuration = resendBalanceDuration
    }
    
    func validateAndVerify(otp: String, completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let otp = try otp.validatedText(validationType: .otp)
            UserRequest
                .emailVerify(params: OTPVerificationRequest.Params(tempUserId: tempUserId, email: email, otp: otp))
                .makeCall(responseType: OTPVerificationRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    if response.otpVerified {
                        UserManager.saveLogined(auth: response.auth!)
                        UserManager.saveLogined(user: response.user!)
                        UserManager.saveSettings(settings: response.settings!)
                        var checkOutUser = UserManager.getCheckOutUser()!
                        checkOutUser.isGuestUser = false
                        UserManager.saveCheckOutUser(user: checkOutUser)
                        completion(true)
                    } else {
                        self.showAlert = true
                    }
                    
                } failure: { (error) in
                    self.toast = error.toast
                    completion(false)
                }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
    
    func resendOtp(completion: @escaping (_ completed: Bool) -> ()) {
        EmailRequest
            .resendOtp(params: EmailRequestData.Params(tempUserId: tempUserId, email: email, otpType: .registration, userId: -1))
            .makeCall(responseType: EmailRequestData.Response.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                self.resetResendBalanceDuration(time: Constants.Number.Duration.OTP_RESEND_TIME_SECONDS)
                completion(true)
            } failure: { (error) in
                completion(false)
            }
    }
    
    func resendCodeTextOnTimerFires() -> String {
        if resendBalanceDuration > 0 {
            resendBalanceDuration -= 1
        }
        return resendCodeText(forCounter: resendBalanceDuration)
    }
    
    private func resendCodeText(forCounter counter: Double) -> String {
        if counter == 0 {
            return "resend_code".localizedString().uppercased()
        } else {
            return Int(counter).secondsToTimeFormatted // >= 10 ? "00 : \(counter)" : "00 : 0\(counter)"
        }
    }
    
    private func resetResendBalanceDuration(time: Double) {
        resendBalanceDuration = time
    }
}
