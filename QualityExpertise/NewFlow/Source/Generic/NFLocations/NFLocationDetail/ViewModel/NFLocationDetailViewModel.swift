//
//  NFLocationDetialViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import UIKit

class NFLocationDetailViewModel: BaseViewModel, ObservableObject {
    @Published var projectDetail:Project?
    var projectID:Int
    
    init(projectID: Int) {
        self.projectID = projectID
    }
    
    func fetchProjectDetail() {
        ProjectRequest.deatils(params: .init(id: projectID)).makeCall(responseType: Project.self) { (isLoading) in
            self.isLoading = isLoading
        } success: { (response) in
            DispatchQueue.main.async {
                self.projectDetail = response
                self.isLoading = false
            }
        } failure: { (error) in
            self.error = error
            self.toast = error.toast
            self.isLoading = false
        }
        
    }
    
}
