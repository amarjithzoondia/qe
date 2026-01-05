//
//  NFPendingActionRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI

class NFPendingActionRowViewModel {
    let pendingActionDetails: NFPendingActionDetails
    
    init(pendingActionDetails: NFPendingActionDetails) {
        self.pendingActionDetails = pendingActionDetails
    }
    
    var timeText: String {
        return Date().timeAgo(from: pendingActionDetails.date.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)?.toLocalTime() ?? Date())
    }
    
    var dateText: String {
        return pendingActionDetails.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)
    }
}
