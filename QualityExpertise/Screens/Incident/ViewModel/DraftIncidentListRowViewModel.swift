//
//  DraftIncidentListRowViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 11/09/25.
//

import Foundation

struct DraftIncidentListRowViewModel {
    
    func date(incident: Incident) -> String {
        incident.incidentDate.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
        
    }
    
    func time(incident: Incident) -> String {
        incident.incidentTime.convertDateFormater(dateFormat: "hh:mm a", inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local)
        
    }
    
    func createdAt(incident: Incident) -> String {
        if let createdAt = incident.createdAt.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local) {
            let local = createdAt.toLocalTime()
            let relativeString = Date().toLocalTime().timeAgo(from: local)
            return relativeString
        }
        
        return "na".localizedString()
    }
}
