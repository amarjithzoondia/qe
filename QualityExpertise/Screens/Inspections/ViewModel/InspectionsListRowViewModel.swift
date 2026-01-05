//
//  InspectionsListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 04/06/25.
//

import UIKit

class InspectionsListRowViewModel {
    let inspection: Inspections
    
    init(inspection: Inspections) {
        self.inspection = inspection
    }
    
    func date() -> String {
        inspection.inspectionDate?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE, local: LocalizationService.shared.language.local) ?? ""
    }
    
    func createdAt() -> String {
        if let createdAt = inspection.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().timeAgo(from: local)
            return relativeString
        }
        
        return "na".localizedString()
    }
}
