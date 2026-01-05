//
//  DraftObservationListRowViewModel.swift
// ALNASR
//
//  Created by developer on 16/02/22.
//

import Foundation

class DraftObservationListRowViewModel: ObservableObject {
    
    func date(date: String) -> String {
        return date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    }
    
    func time(createdTime: String, updatedTime: String = "") -> String {
        if updatedTime == "" {
            return Date().timeAgo(from: createdTime.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") ?? Date())
        } else {
            return Date().timeAgo(from: updatedTime.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") ?? Date())
        }
    }
}
