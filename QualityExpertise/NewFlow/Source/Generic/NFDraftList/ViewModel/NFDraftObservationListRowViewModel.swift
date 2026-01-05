//
//  NFDraftObservationListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation

class NFDraftObservationListRowViewModel: ObservableObject {
    
    func date(date: String) -> String {
        return date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)
    }
    
    func time(createdTime: String, updatedTime: String = "") -> String {
        return Date().timeAgo(from: createdTime.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local) ?? Date())
        
    }
}
