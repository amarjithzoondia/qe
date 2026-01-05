//
//  ProjectListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 09/04/25.
//

import UIKit

class ProjectListRowViewModel: BaseViewModel, ObservableObject {
    @Published var project:Project
    
    init(project: Project) {
        self.project = project
    }
}
