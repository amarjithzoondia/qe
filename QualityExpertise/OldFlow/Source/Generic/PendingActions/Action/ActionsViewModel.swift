//
//  ActionsViewModel.swift
// ALNASR
//
//  Created by developer on 02/03/22.
//

import Foundation

class ActionsViewModel: BaseViewModel, ObservableObject {
    var pdfUrl: String = Constants.EMPTY_STRING
    
    func generatePdf(observationId: Int, completion: @escaping (_ completed: Bool) -> ()) {
        ObservationRequest
            .generatePdf(params: .init(observationId: observationId))
            .makeCall(responseType: ObservationDetailRequest.GeneratePDFResponse.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                self.pdfUrl = response.pdfUrl
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func approveOrReject(id: Int, actionType: ActionType, completion: @escaping (_ completed: Bool) -> ()) {
        PendingActionRequest
            .action(params: .init(id: id, action: actionType))
            .makeCall(responseType: PendingActionRequest.ActionResponse.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }

    }
}
