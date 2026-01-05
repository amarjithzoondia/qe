//
//  GroupCreationViewModel.swift
// ALNASR
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
        return "Successfully" + Constants.NEXT_LINE + "Generated Code"
    }
}
