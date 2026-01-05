//
//  DraftViolationListRowViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

import Foundation

struct DraftViolationListRowViewModel {
    
    func date(violation: Violation) -> String {
        violation.violationDate.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE, local: LocalizationService.shared.language.local)
    }
    
    func createdAt(violation: Violation) -> String {
        if let createdAt = violation.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().toLocalTime().timeAgo(from: local)
            return relativeString
        }
        
        return "na".localizedString()
    }
}
