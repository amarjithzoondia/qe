//
//  PreTaskListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 24/10/25.
//


import UIKit

struct PreTaskListRowViewModel {
    func date(preTask: PreTask) -> String {
        preTask.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE, local: LocalizationService.shared.language.local)
        
    }
    
    func time(preTask: PreTask) -> String {
        preTask.startTime?.convertDateFormater(dateFormat: "hh:mm a", inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local) ?? ""
        
    }
    
    func createdAt(preTask: PreTask) -> String {
        if let createdAt = preTask.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().timeAgo(from: local)
            return relativeString
        }
        return "na".localizedString()
    }
}
