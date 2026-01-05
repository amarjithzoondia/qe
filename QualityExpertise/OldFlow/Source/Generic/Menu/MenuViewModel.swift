//
//  MenuViewModel.swift
// ALNASR
//
//  Created by developer on 31/01/22.
//

import SwiftUI

class MenuViewModel: BaseViewModel, ObservableObject {
    @Published var user = UserManager().user

    func logoutUser(completed: @escaping () -> ()) {
        UserRequest
            .logOut
            .makeCall(responseType: CommonResponse.self) { (isLoading) in
                self.showActionsLoader(loading: isLoading)
            } success: { result in
                DispatchQueue.main.async {
                    UserManager.logout(gotoLoginScreen: true)
                    completed()
                }
            } failure: { (error) in
                self.toast = error.toast
            }
    }
}

