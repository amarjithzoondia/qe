//
//  NFDeleteObservationRequestViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation

class NFDeleteObservationRequestViewModel: BaseViewModel, ObservableObject {
    let observationId: Int
    
    internal init(observationId: Int) {
        self.observationId = observationId
    }
    
    func requestToDeleteObservation(justification: String, completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let justification = try justification.validatedText(validationType: .requiredField(field: "description".localizedString()))
            
            NFObservationsRequest
                .deleteRequest(params: .init(observationId: observationId, justification: justification))
                .makeCall(responseType: CommonResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    completion(true)
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        } catch {
            DispatchQueue.main.async {
                self.toast = (error as! SystemError).toast
            }
        }
    }
}
