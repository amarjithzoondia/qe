//
//  DraftObservationListViewModel.swift
// QualityExpertise
//
//  Created by developer on 16/02/22.
//

import Foundation

class DraftObservationListViewModel: BaseViewModel, ObservableObject {
    @Published var observations: [ObservationDraftData] = []
}
