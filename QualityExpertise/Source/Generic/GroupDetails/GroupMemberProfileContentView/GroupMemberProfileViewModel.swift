//
//  MemberProfileViewModel.swift
// QualityExpertise
//
//  Created by developer on 22/02/22.
//

import Foundation

class GroupMemberProfileViewModel: BaseViewModel, ObservableObject {
    let userId: Int?
    var member: User?
    init(userId: Int) {
        self.userId = userId
    }
    
    func fetchMemberDetail() {
        GroupRequest
            .memberProfile(params: .init(userId: userId ?? -1))
            .makeCall(responseType: User.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                self.member = response
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
