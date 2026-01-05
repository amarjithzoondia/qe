//
//  AboutUsViewModel.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import Foundation

class AboutUsViewModel: BaseViewModel, ObservableObject {
    @Published var content: String = ""
    @Published var overview: String = ""
    
    override func fetchDetails() {
        super.fetchDetails()
        
        AboutUsRequest
            .aboutUs
            .makeCall(responseType: AboutUsRequestResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (result) in
                DispatchQueue.main.async {
                    self.content = result.description
                    self.overview = result.overview
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
