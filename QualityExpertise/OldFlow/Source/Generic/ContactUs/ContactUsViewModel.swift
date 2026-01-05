//
//  ContactUsViewModel.swift
// ALNASR
//
//  Created by developer on 09/02/22.
//

import Foundation

class ContactUsViewModel: BaseViewModel, ObservableObject {
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var address: String = ""
    
    override func fetchDetails() {
        super.fetchDetails()
        
        ContactUsRequest
            .contactUs
            .makeCall(responseType: ContactUsInfo.Response.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (result) in
                DispatchQueue.main.async {
                    self.email = result.email
                    self.phone = result.phone
                    self.address = result.address
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func sendMessage(message: String) {
        ContactUsRequest
            .sendMessage(params: .init(name: UserManager().user?.name ?? "", email: UserManager().user?.email ?? "", message: message))
            .makeCall(responseType: ContactUsInfo.SendMessageResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (result) in
                DispatchQueue.main.async {
                    self.toast = "Message Posted Successfully".localizedString().successToast
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
