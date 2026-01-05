//
//  DeleteAccountViewModel.swift
// ALNASR
//
//  Created by Developer on 21/07/22.
//

import Foundation

class DeleteAccountViewModel: BaseViewModel, ObservableObject {
    
    @Published var isButtonLoading: Bool = false
    @Published var email: String = ""
    @Published var tempUserId: Int = -1
    @Published var isResendButtonActive: Bool = true
    @Published var isResendLoading: Bool = false
    var deletionContent: String?
    var isGuestUser: Bool = UserManager.getCheckOutUser()?.isGuestUser ?? false
    var deletionMessage: String = ""
    var resendBalanceDuration = Constants.Number.Duration.OTP_RESEND_TIME_SECONDS
    @Published var verifyDeleteResponse: DeleteVerifyRequestResponse?
    
    func verifyPassword(password: String) {
        do {
            let password = try password.validatedText(validationType: .requiredField(field: "Password"))
            
            UserRequest
                .delete(params: .init(password: password))
                .makeCall(responseType: DeleteUserRequestResponse.self) { isLoading in
                    self.isActionsLoading = isLoading
                } success: { response in
                    self.deletionContent = response.content
                } failure: { error in
                    self.toast = error.toast
                }
            
        } catch {
            toast = (error as! SystemError).toast
        }
    }
    
    func verifyDelete(otp: String = "", completion: @escaping (Bool)-> ()) {
        if isGuestUser {
            GuestRequest
                .delete(param: .init(guestUserId: UserManager.getCheckOutUser()?.userId ?? -1))
                .makeCall(responseType: DeleteVerifyRequestResponse.self) { isLoading in
                    self.isButtonLoading = isLoading
                } success: { response in
                    self.verifyDeleteResponse = response
                    completion(true)
                } failure: { error in
                    self.toast = error.toast
                    completion(false)
                }
            
        } else {
            do {
                let otp = try otp.validatedText(validationType: .requiredField(field: "OTP"))
                var refreshToken = ""
                if let auth = getLoginedAuth() {
                    refreshToken = auth.refresh
                }
                    
                UserRequest
                    .deleteVerify(params: .init(otp: otp, refresh: refreshToken))
                    .makeCall(responseType: DeleteVerifyRequestResponse.self) { isLoading in
                        self.isButtonLoading = isLoading
                    } success: { response in
                        self.verifyDeleteResponse = response
                        completion(true)
                    } failure: { error in
                        self.toast = error.toast
                        completion(false)
                    }
                
            } catch {
                toast = (error as! SystemError).toast
            }
        }
    }
    
    func fetchTerms() {
        self.error = nil
        UserRequest
            .deleteTerms(params: DeleteTermsParams(isGuestUser: isGuestUser))
            .makeCall(responseType: DeleteTermsRequest.self) { isLoading in
                self.isLoading = isLoading
            } success: { response in
                self.deletionMessage = response.content
            } failure: { error in
                self.toast = error.toast
                self.error = error
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
            isResendButtonActive = true
            return "Resend Code"
        } else {
            isResendButtonActive = false
            return Int(counter).secondsToTimeFormatted // >= 10 ? "00 : \(counter)" : "00 : 0\(counter)"
        }
    }
    
    private func resetResendBalanceDuration(time: Double) {
        isResendButtonActive = false
        resendBalanceDuration = time
    }
    
    func resendOtp(completion: @escaping (_ completed: Bool) -> ()) {
        EmailRequest
            .resendOtp(params: EmailRequestData.Params(tempUserId: tempUserId, email: email, otpType: .delete, userId: UserManager().user?.userId ?? -1))
            .makeCall(responseType: EmailRequestData.Response.self) { (isLoading) in
                self.isResendLoading = isLoading
            } success: { (response) in
                self.resetResendBalanceDuration(time: Constants.Number.Duration.OTP_RESEND_TIME_SECONDS)
                self.toast = response.statusMessage.successToast
                completion(true)
            } failure: { (error) in
                self.toast = error.toast
                completion(false)
            }
    }
    
    func getLoginedAuth() -> Auth? {
        let defaults = UserDefaults.standard
        if let savedAuth = defaults.object(forKey: "LOGINED_AUTH") as? Data {
            let decoder = JSONDecoder()
            if let auth = try? decoder.decode(Auth.self, from: savedAuth) {
                return auth
            }
        }
        return nil
    }
}
