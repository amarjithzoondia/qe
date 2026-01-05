//
//  NFObservationListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI

class NFObservationListRowViewModel {
    let observation: Observation
    
    init(observation: Observation) {
        self.observation = observation
    }
    
    var remainingImagesCount: String {
        let count = observation.totalImages - 2
        return Constants.ADD + count.string
    }
    
    var date: String {
        return observation.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)
    }
    
    var time : String {
        return Date().timeAgo(from: observation.date.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)?.toLocalTime() ?? Date())
    }
}
