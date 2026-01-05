//
//  PendingActionRowViewModel.swift
// ALNASR
//
//  Created by developer on 02/03/22.
//

import SwiftUI

class PendingActionRowViewModel {
    let pendingActionDetails: PendingActionDetails
    
    init(pendingActionDetails: PendingActionDetails) {
        self.pendingActionDetails = pendingActionDetails
    }
    
    var timeText: String {
        return Date().timeAgo(from: pendingActionDetails.date.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")?.toLocalTime() ?? Date())
    }
    
    var dateText: String {
        return pendingActionDetails.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    }
}
