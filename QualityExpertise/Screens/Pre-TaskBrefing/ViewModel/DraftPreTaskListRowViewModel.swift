//
//  DraftPreTaskListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 28/10/25.
//


import Foundation

struct DraftPreTaskListRowViewModel {
    
    func date(preTask: PreTask) -> String {
        preTask.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE, local: LocalizationService.shared.language.local)
        
    }
    
    func time(preTask: PreTask) -> String {
        preTask.startTime?.convertDateFormater(dateFormat: "hh:mm a", inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local) ?? ""
        
    }
    
    func createdAt(preTask: PreTask) -> String {
        if let createdAt = preTask.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().toLocalTime().timeAgo(from: local)
            return relativeString
        }
        
        return "na".localizedString()
    }
}
