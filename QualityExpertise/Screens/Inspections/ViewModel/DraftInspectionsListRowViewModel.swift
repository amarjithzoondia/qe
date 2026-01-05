//
//  DraftInspectionsListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 01/08/25.
//

import Foundation

struct DraftInspectionsListRowViewModel {
    
    func createdAt(inspection: Inspections) -> String {
        if let createdAt = inspection.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().toLocalTime().timeAgo(from: local)
            return relativeString
        }
        
        return "na".localizedString()
    }
    
    func date(inspection: Inspections) -> String {
        return inspection.inspectionDate?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE, local: LocalizationService.shared.language.local) ?? ""
    }
}
