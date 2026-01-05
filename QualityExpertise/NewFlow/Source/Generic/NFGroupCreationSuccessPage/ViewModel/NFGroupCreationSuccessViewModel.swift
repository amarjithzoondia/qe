//
//  NFGroupCreationSuccessViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation

class NFGroupCreationSuccessViewModel {
    
    var groupDetails: GroupData = GroupData.dummy()
    
    init(groupdetails: GroupData) {
        self.groupDetails = groupdetails
    }
    
    var titleString: String {
        return "sucessfully_generated_code".localizedString()
    }
}
