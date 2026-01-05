//
//  NFLocationListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import UIKit

class NFLocationListViewModel: BaseViewModel, ObservableObject {
    @Published var projects:[Project] = []
    
    func fetchProjects(searchText:String?) {
        self.error = nil
        ProjectRequest.list(params: .init(name: searchText)).makeCall(responseType: [Project].self) { (isLoading) in
            self.isLoading = isLoading
        } success: { (response) in
            DispatchQueue.main.async {
                self.projects = response
                self.isLoading = false
            }
        } failure: { (error) in
            self.error = error
            self.toast = error.toast
            self.isLoading = false
        }
        
    }
}
