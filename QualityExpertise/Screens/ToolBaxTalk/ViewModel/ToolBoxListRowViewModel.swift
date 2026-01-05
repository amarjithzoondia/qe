//
//  ToolBoxListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

import UIKit

struct ToolBoxListRowViewModel {
    func date(toolBoxTalk: ToolBoxTalk) -> String {
        toolBoxTalk.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
        
    }
    
    func time(toolBoxTalk: ToolBoxTalk) -> String {
        toolBoxTalk.startTime.convertDateFormater(dateFormat: "hh:mm a", inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local)
        
    }
    
    func createdAt(toolBoxTalk: ToolBoxTalk) -> String {
        if let createdAt = toolBoxTalk.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().timeAgo(from: local)
            return relativeString
        }
        return "na".localizedString()
    }
}
