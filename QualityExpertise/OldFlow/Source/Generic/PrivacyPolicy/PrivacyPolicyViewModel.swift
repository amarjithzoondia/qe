//
//  PrivacyPolicyViewModel.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import Foundation

class PrivacyPolicyViewModel: BaseViewModel, ObservableObject {
    @Published var content: String = ""
    
    override func fetchDetails() {
        super.fetchDetails()
        
        GeneralRequest
            .staticContents(params: .init(type: .privacyPolicy))
            .makeCall(responseType: GeneralRequest.StaticContentResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.showLoader(loading: isLoading)
                }
            } success: { (result) in
                DispatchQueue.main.async {
                    self.content = result.content
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
