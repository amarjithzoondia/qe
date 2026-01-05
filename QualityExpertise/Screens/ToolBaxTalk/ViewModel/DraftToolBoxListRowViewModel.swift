//
//  DraftToolBoxListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 11/09/25.
//

import Foundation

struct DraftToolBoxListRowViewModel {
    
    func date(toolBox: ToolBoxTalk) -> String {
        toolBox.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
        
    }
    
    func time(toolBox: ToolBoxTalk) -> String {
        toolBox.startTime.convertDateFormater(dateFormat: "hh:mm a", inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local)
        
    }
    
    func createdAt(toolBox: ToolBoxTalk) -> String {
        if let createdAt = toolBox.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().toLocalTime().timeAgo(from: local)
            return relativeString
        }
        
        return "na".localizedString()
    }
}
