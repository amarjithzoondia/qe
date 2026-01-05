//
//  CheckOutUser.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//

import Foundation

struct CheckOutUser: Codable {
    
    var userId: Int
    var uuid: String
    var isGuestUser: Bool
    var guestDetails: GuestDetails?
    var userDetails: UserDetails?
    
    init(uuid: String, userId: Int, isGuestUser: Bool, guestDetails: GuestDetails?, userDetails: UserDetails?) {
        self.uuid = uuid
        self.userId = userId
        self.isGuestUser = isGuestUser
        self.guestDetails = guestDetails
        self.userDetails = userDetails
    }
}
