//
//  LessonLearnedListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/07/25.
//

import UIKit

struct LessonLearnedListRowViewModel {
    func date(lesson: LessonLearned) -> String {
        lesson.createdAt.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
    }
    
    func createdAt(lesson: LessonLearned) -> String {
        if let createdAt = lesson.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().timeAgo(from: local)
            return relativeString
        }
        
        return "na".localizedString()
    }
}
