//
//  ChnagePasswordViewModel.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import Combine
import SwiftUI

class ChangePasswordViewModel: BaseViewModel, ObservableObject {
    func changePassword(
        old: String,
        new: String,
        confirmNew: String,
        completed: @escaping () -> ()
    ) {
        do {
            let oldPassword = try old.validatedText(validationType: .password)
            let newPassword = try new.validatedText(validationType: .password)
            _ = try confirmNew.validatedText(validationType: .matchingField(field: "password".localizedString(), with: newPassword))

            CommonRequest
                .changePassword(params: .init(oldPassword: oldPassword, newPassword: newPassword))
                .makeCall(responseType: ChangePasswordRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.toast = response.statusmessage.successToast
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        completed()
                    }
                } failure: { (error) in
                    self.toast = error.toast
                }

        } catch {
            toast = (error as! SystemError).toast
        }
    }
}

