//
//  ProjectDetailViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 10/04/25.
//

import UIKit

class ProjectDetailViewModel: BaseViewModel, ObservableObject {
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
