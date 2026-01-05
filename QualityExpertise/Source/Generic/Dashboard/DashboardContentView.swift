//
//  DashboardContentView.swift
// QualityExpertise
//
//  Created by developer on 21/01/22.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

struct DashboardContentView: View {
    
    @StateObject var viewModel = DashboardViewModel()
    var isGuest = UserManager.getCheckOutUser()?.isGuestUser
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var alert: Bool = false
    let reLaunchAppPublisher = NotificationCenter.default.publisher(for: .RELAUNCH_APP)
    @StateObject private var userManager = UserManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color.Grey.PALE
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack {
                        VStack(spacing: 0) {
                            if viewModel.addTrackingAuthStatus != .notDetermined {
                                GADBannerViewController()
                                    .frame(height: 60)
                                    .padding(.horizontal, 28)
                            }
                            
                            observationView
                            
                            Spacer()
                        }
                        .padding(.top, 20.5)
                        .background(Color.white.cornerRadius(30, corners: [.bottomLeft, .bottomRight]))
                        
                        groupview
                            .padding(.vertical, 48)
                            .padding(.horizontal, 28)
                            .background(Color.Grey.PALE)
                            .opacity(isGuest ?? false ? 0.25 : 1.0)
                        
                    }
                    .background(Color.Grey.PALE)
                    .padding(.bottom, isGuest ?? false ? 25 + 41 : 25)
                }
                .background(Color.Grey.PALE)
                
                if isGuest ?? false {
                    VStack {
                        Spacer()
                        ZStack {
                            HStack(spacing: 0){
                                Spacer()
                                
                                Button {
                                    viewControllerHolder?.present(style: .overCurrentContext) {
                                        RegisterContentView(isFromHome: true)
                                            .localize()
                                    }
                                } label: {
                                    Text("register".localizedString())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, maxHeight: 45)
                                }
                                .background(Color.Blue.THEME)
                                
                                Button {
                                    viewControllerHolder?.present(style: .overCurrentContext) {
                                        LogInContentView()
                                            .localize()
                                    }
                                } label: {
                                    Text("login".localizedString())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, maxHeight: 45)
                                }
                                .background(Color.Blue.THEME)
                                
                                Spacer()
                            }
                            .frame(minHeight: 45)
                            .background(Color.Blue.THEME)
                            .cornerRadius(22.5)
                            
                            if isGuest ?? false {
                                Button {
                                    viewControllerHolder?.present(style: .overCurrentContext) {
                                        MoreMenuContentView()
                                            .localize()
                                    }
                                } label: {
                                    Image(IC.LOGO.DASH)
                                        .resizable()
                                        .frame(maxWidth: 55, maxHeight: 55, alignment: .center)
                                        .clipped()
                                }
                                .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                                .background(Color.white)
                                .cornerRadius(36.25)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 63.5)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitle("observation".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss()
                })
            }
            .toast(isPresenting: $alert, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .onReceive(reLaunchAppPublisher) { (output) in
                AppState.resetApp()
            }
            .listenToAppNotificationClicks()
            .onAppear {
                viewModel.requestIDFA()
                if !(isGuest ?? false) {
                    viewModel.checkRole()
                }
            }
            
        }
    }
    
    var observationView: some View {
        VStack(spacing: 0) {
            Text("observations".localizedString())
                .font(.semiBold(17))
                .foregroundColor(Color.Indigo.DARK)
                .leftAlign()
            
            observationContentView
                .padding(.top, 22)
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 28)
    }
    
    var observationContentView: some View {
        VStack(spacing: 13.5) {
            Button {
                viewControllerHolder?.present(style: .overCurrentContext) {
                    CreateObservationContentView(draftObservation: .constant(ObservationDraftData(id: -1, observationTitle: "", reportedBy: "", location: "", description: "", responsiblePersonName: "", imageDescription: [], createdTime: "", updatedTime: "")))
                        .localize()
                }
            } label: {
                HStack(spacing: 9.5) {
                    Image(IC.DASHBOARD.CREATE_OBSERVATION)
                    
                    LeftAlignedHStack(
                        Text("create_observation".localizedString())
                            .font(.regular(12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4)
                    )
                    
                    Spacer()
                }
                .padding(.vertical, 15)
                .padding(.leading, 11.5)
            }
            .frame(maxWidth: .infinity, maxHeight: 66.5)
            .background(
                LinearGradient(gradient: Gradient(colors: [
                    Color.Green.SOFT,
                    Color.Green.DARK_MINT
            ]),
            startPoint: .leading,
            endPoint: .trailing))
            .cornerRadius(9)
            
            HStack(spacing: 10) {
                Button {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ObservationListContentView()
                            .localize()
                    }
                } label: {
                    VStack {
                        LeftAlignedHStack(
                            Image(IC.DASHBOARD.VIEW_OBSERVATION)
                        )
                        
                        Spacer()
                        
                        LeftAlignedHStack(
                            Text("view_observations".localizedString())
                                .font(.regular(12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(4)
                        )
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 11.5)
                }
                .frame(height: 97)
                .background(
                    LinearGradient(gradient: Gradient(colors: [
                        Color.Blue.CAROLINA,
                        Color.Blue.CORN_FLOWER
                ]),
                startPoint: .leading,
                endPoint: .trailing))
                .cornerRadius(9)
                
                Button {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        DraftObservationListContentView()
                            .localize()
                    }
                } label: {
                    VStack{
                        LeftAlignedHStack(
                            Image(IC.DASHBOARD.DRAFT_OBSERVATION)
                        )
                        
                        Spacer()
                        
                        LeftAlignedHStack(
                            Text(viewModel.observationDraftText)
                                .font(.regular(12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(4)
                        )
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 11.5)
                }
                .frame(height: 97)
                .background(
                    LinearGradient(gradient: Gradient(colors: [
                        Color.Red.WHEAT,
                        Color.Red.SALMON
                ]),
                startPoint: .leading,
                endPoint: .trailing))
                .cornerRadius(9)
                
                Button {
                    if isGuest ?? false {
                        self.alert = true
                    } else {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            PendingActionsListContentView()
                                .localize()
                        }
                    }
                } label: {
                    VStack{
                        HStack {
                            ZStack(alignment: .topTrailing) {
                                Image(IC.DASHBOARD.TAB.PENDING_ACTIONS)
                                    .renderingMode(.template)
                                    .foregroundColor(Color.white)
                                
                                if userManager.pendingActionsCount > 0 {
                                    Circle()
                                        .foregroundColor(Color.Red.CORAL)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 3)
                                }
                            }
                            Spacer()
                        }
                        
                        Spacer()
                        
                        LeftAlignedHStack(
                            Text("pending_actions".localizedString())
                                .font(.regular(12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(4)
                        )
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 11.5)
                }
                .frame(height: 97)
                .background(isGuest ?? false ? LinearGradient(gradient: Gradient(colors: [Color.Blue.BRIGHT_SKY_BLUE.opacity(0.25), Color.Blue.BRIGHT_CYAN_TWO.opacity(0.25)]), startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(gradient: Gradient(colors: [
                        Color.Blue.BRIGHT_SKY_BLUE,
                        Color.Blue.BRIGHT_CYAN_TWO
                ]),
                startPoint: .leading,
                endPoint: .trailing))
                .cornerRadius(9)
            }
        }
    }
    
    var groupview: some View {
        VStack(spacing: 0) {
            LeftAlignedHStack(
                Text("groups".localizedString())
                    .font(.semiBold(17))
                    .foregroundColor(Color.Indigo.DARK)
            )
            
            groupContentsView
                .padding(.top, 18.5)
        }
    }
    
    var groupContentsView: some View {
        VStack(spacing: 13) {
            HStack(spacing: 16) {
                Button {
                    if isGuest ?? false {
                        self.alert = true
                    } else {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            CreateGroupContentView(viewModel: .init(isEditing: false, groupName: "", description: "", image: "", groupCode: ""))
                                .localize()
                        }
                    }
                } label: {
                    VStack {
                        Image(IC.DASHBOARD.CREATE_GROUP)
                            .padding(.top, 10)
                        
                        Text(viewModel.createGroupText)
                            .padding(.bottom, 9)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(12.8))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color.white)
                .cornerRadius(9)
                
                Button {
                    if isGuest ?? false {
                        self.alert = true
                    } else {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            GroupListContentView(isFromViewGroup: true, isActive: .constant(false), groupData: .constant(GroupData.dummy()))
                                .localize()
                        }
                    }
                } label: {
                    VStack {
                        Image(IC.DASHBOARD.VIEW_GROUP)
                            .padding(.top, 10)
                        
                        Text(viewModel.viewGoupText)
                            .padding(.bottom, 9)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(12.8))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color.white)
                .cornerRadius(9)
            }
            
            HStack(spacing: 16) {
                Button {
                    if isGuest ?? false {
                        self.alert = true
                    } else {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            RequestAccessContentView()
                                .localize()
                        }
                    }
                } label: {
                    VStack {
                        Image(IC.DASHBOARD.REQUEST_GROUP)
                            .padding(.top, 10)
                        
                        Text(viewModel.resuestGroupText)
                            .padding(.bottom, 9)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(12.8))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color.white)
                .cornerRadius(9)
                
                Button {
                    if isGuest ?? false {
                        self.alert = true
                    } else {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            InviteUserContentView(viewModel: .init(groupData: GroupData.dummy()), isFromDashboard: true)
                                .localize()
                        }
                    }
                } label: {
                    VStack {
                        Image(IC.DASHBOARD.INVITE_GROUP)
                            .padding(.top, 10)
                        
                        Text(viewModel.inviteGroupText)
                            .padding(.bottom, 9)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(12.8))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color.white)
                .cornerRadius(9)
            }
        }
    }
}

struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView()
    }
}
