//
//  GroupCreationViewModel.swift
// QualityExpertise
//
//  Created by developer on 27/01/22.
//

import Foundation

class GroupCreationSuccessViewModel {
    
    var groupDetails: GroupData = GroupData.dummy()
    
    init(groupdetails: GroupData) {
        self.groupDetails = groupdetails
    }
    
    var titleString: String {
        return "sucessfully_generated_code".localizedString()
    }
}
