//
//  ResponsiblePersonChangeViewModel.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import Foundation
import SwiftUI

class ResponsiblePersonChangeViewModel: BaseViewModel, ObservableObject {
    @Published var groupData = GroupData.dummy()
    @Published var observationId: Int = -1
    
    internal init(groupData: GroupData, observationId: Int) {
        self.groupData = groupData
        self.observationId = observationId
    }
    
    func responsiblePersonChange(description: String, userId: Int,completion: @escaping (_ completed: Bool) -> ()) {
        do {
            guard userId > 0  else {
                throw SystemError("select_a_user".localizedString())
            }
            let description = try description.validatedText(validationType: .requiredField(field: "description".localizedString()))
            ObservationRequest
                .changeResponsiblePerson(params: .init(observationId: observationId, justification: description, responsiblePerson: userId))
                .makeCall(responseType: CommonResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (result) in
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
