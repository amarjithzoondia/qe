//
//  NFLocaionListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import UIKit

class NFLocaionRowViewModel: BaseViewModel, ObservableObject {
    @Published var project:Project
    
    init(project: Project) {
        self.project = project
    }
}
