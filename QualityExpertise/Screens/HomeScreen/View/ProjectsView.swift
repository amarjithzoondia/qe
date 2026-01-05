//
//  ProjectsView.swift
//  ALNASR
//
//  Created by Amarjith B on 18/07/25.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    var isGuest = UserManager.getCheckOutUser()?.isGuestUser
    var body: some View {
        NavigationView {
            ZStack {
                Color.Grey.PALE
                    .ignoresSafeArea()
                
                VStack {
                    Text("facilities_projects".localizedString())
                        .font(.medium(17))
                        .foregroundColor(Color.black)
                        .padding(.vertical, 28)
                    
                    Group {
                        VStack(alignment: .leading, spacing: 10) {
                            ProjectTitleBar(iconName: IC.DASHBOARD.VIEW_GROUP, title: "view_project".localizedString()){
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    NFGroupListContentView(isFromViewGroup: true, isActive: .constant(false), groupData: .constant(GroupData.dummy()))
                                        .localize()
                                }
                            }
                            ProjectTitleBar(iconName: IC.DASHBOARD.REQUEST_GROUP, title: "request_access".localizedString()){
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    NFRequestAccessContentView()
                                        .localize()
                                }
                            }
                            ProjectTitleBar(iconName: IC.DASHBOARD.CREATE_GROUP, title: "create_new".localizedString()){
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    NFCreateGroupContentView(viewModel: .init(isEditing: false, groupName: "", description: "", image: "", groupCode: ""))
                                        .localize()
                                }
                            }
                            ProjectTitleBar(iconName: IC.DASHBOARD.INVITE_GROUP, title: "invite_users".localizedString()){
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    NFInviteUserContentView(viewModel: .init(groupData: GroupData.dummy()), isFromDashboard: true)
                                        .localize()
                                }
                            }
                        }
//                        .padding(.bottom, 24)
                    }
                    
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                
                
                
                
            }
        }
    }
}

extension ProjectsView {
    struct ProjectTitleBar: View {
        var iconName: String
        var title: String
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 14) {
                    Image(iconName)
                    Text(title)
                        .font(.light(13))
                        .foregroundColor(Color.black)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(.allCorners, 9)
            }
        }
    }
}


#Preview {
    ProjectsView()
}
