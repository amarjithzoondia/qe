//
//  HomeScreenView.swift
//  ALNASR
//

import SwiftUI

struct HomeScreenView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?

    @StateObject private var viewModel = HomeScreenViewModel()
    @State private var showLogoutAlert = false
    @State private var showComingSoonAlert = false

    private let reLaunchAppPublisher = NotificationCenter.default.publisher(for: .RELAUNCH_APP)

    private var isGuest: Bool { UserManager.getCheckOutUser()?.isGuestUser ?? true }
    private var userType: UserType { UserManager.getLoginedUser()?.userType ?? .normalUser }
    private var isGroupAdmin: Bool { UserManager.getIsGroupAdmin() }


    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.white
                    .ignoresSafeArea()
                mainScrollView
                if isGuest { guestBottomButtons }
                if showComingSoonAlert { comingSoonToast }
            }
            .toast(isPresenting: $viewModel.showToast,
                   duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .alert(isPresented: $showLogoutAlert, content: logoutAlert)
            .onReceive(reLaunchAppPublisher) { _ in AppState.resetApp() }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

private extension HomeScreenView {

    // MARK: - Main ScrollView
    var mainScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topSection
                dividerBar

                HomeScreenIconsView(showToast: $showComingSoonAlert)
                    .disabled(isGuest)
                    .opacity(isGuest ? 0.5 : 1)
                    .padding(.top, 20)

                dividerBar
                projectsSectionView
                    .disabled(isGuest)
                    .opacity(isGuest ? 0.5 : 1)

            }
            .onAppear {
                if !isGuest {
                    viewModel.checkRole()
                    viewModel.getInspectionsContentList()
                    viewModel.getAuditsInspectionForms()
                    viewModel.getPreTaskContentsList()
                }
            }
        }
        .background(Color.white)
    }

    // MARK: - Top Section
    var topSection: some View {
        VStack(spacing: 0) {

            if !isGuest {
                HStack {
                    Spacer()
                    Button("logout".localizedString()) {
                        showLogoutAlert = true
                    }
                    .font(.regular(16))
                    .foregroundColor(Color.Indigo.DARK)
                    .padding(.trailing, 28)
                    .padding(.top, 10)
                }
            }

            Image(IC.LOGO.ABOUT_US)
                .resizable()
                .frame(width: 150, height: 123)
                .padding(.top, 20)

            ObservationButton()
                .padding(.horizontal, 24)
                .padding(.vertical, 30)
                .onTapGesture { openWorkflow() }
        }
        .background(Color.white)
        .padding(.top, 20)
    }

    func openWorkflow() {
        viewControllerHolder?.present(style: .overCurrentContext) {
            isGuest
            ? AnyView(DashboardContentView().localize())
            : AnyView(CustomTabBarContentView().localize())
        }
    }

    // MARK: - Divider
    var dividerBar: some View {
        Divider()
            .frame(height: 25)
            .background(Color.Blue.THEME)
    }

    // MARK: - Projects Section
    var projectsSectionView: some View {
        VStack {
            Text("facilities_projects".localizedString())
                .font(.medium(17))
                .foregroundColor(.black)
                .padding(.vertical, 28)

            VStack(alignment: .leading, spacing: 10) {
                projectItem(icon: IC.DASHBOARD.VIEW_GROUP,
                            title: "view_project",
                            action: openViewGroup)

                projectItem(icon: IC.DASHBOARD.REQUEST_GROUP,
                            title: "request_access",
                            action: openRequestAccess)

                projectItem(icon: IC.DASHBOARD.CREATE_GROUP,
                            title: "create_new",
                            action: openCreateGroup)
                    .disabled(userType == .normalUser)
                    .opacity(userType == .normalUser ? 0.5 : 1)

                projectItem(icon: IC.DASHBOARD.INVITE_GROUP,
                            title: "invite_users",
                            action: openInviteUsers)
                    .disabled(userType == .normalUser && !isGroupAdmin)
                    .opacity(userType == .normalUser && !isGroupAdmin ? 0.5 : 1)
            }
            .padding(.bottom, isGuest ? 100 : 150)
        }
        .padding(.horizontal, 24)
        .background(Color.Grey.PALE)
    }

    func projectItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        ProjectTitleBar(iconName: icon,
                        title: title.localizedString(),
                        action: action)
    }

    func openViewGroup() {
        viewControllerHolder?.present(style: .overCurrentContext) {
            NFGroupListContentView(
                isFromViewGroup: true,
                isActive: .constant(false),
                groupData: .constant(GroupData.dummy())
            ).localize()
        }
    }

    func openRequestAccess() {
        viewControllerHolder?.present(style: .overCurrentContext) {
            NFRequestAccessContentView().localize()
        }
    }

    func openCreateGroup() {
        viewControllerHolder?.present(style: .overCurrentContext) {
            NFCreateGroupContentView(
                viewModel: .init(isEditing: false,
                                 groupName: "",
                                 description: "",
                                 image: "",
                                 groupCode: ""))
            .localize()
        }
    }

    func openInviteUsers() {
        viewControllerHolder?.present(style: .overCurrentContext) {
            NFInviteUserContentView(
                viewModel: .init(groupData: GroupData.dummy()),
                isFromDashboard: true
            ).localize()
        }
    }

    // MARK: - Guest Bottom Bar
    var guestBottomButtons: some View {
        VStack {
                                    Spacer()
                                    ZStack {
                                        HStack(spacing: 0) {
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

                                        if isGuest {
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
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 20)
                                }
                            

    }

    func bottomButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 45)
        }
        .background(Color.Blue.THEME)
    }

    // Middle Floating Button
    var centerMenuButton: some View {
        Button {
            viewControllerHolder?.present(style: .overCurrentContext) {
                MoreMenuContentView().localize()
            }
        } label: {
            Image(IC.LOGO.DASH)
                .resizable()
                .frame(width: 55, height: 55)
                .background(Color.white)
                .cornerRadius(36)
        }
    }

    // MARK: - Coming Soon Toast
    var comingSoonToast: some View {
        VStack {
            Spacer()
            Text("coming_soon".localizedString())
                .font(.medium(12))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.7))
                .cornerRadius(30)
                .padding(.bottom, 80)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation { showComingSoonAlert = false }
            }
        }
    }

    // MARK: - Logout Alert
    func logoutAlert() -> Alert {
        Alert(
            title: Text("logout_confirmation".localizedString()),
            primaryButton: .destructive(Text("logout_yes".localizedString())) {
                viewModel.logoutUser { }
            },
            secondaryButton: .cancel(Text("cancel".localizedString()))
        )
    }
}

// MARK: - Supporting Views
struct ObservationButton: View {
    var body: some View {
        HStack(spacing: 20) {
            Image(IC.HOMESCREEN.TOOLBOX)
            Text("open_workflow".localizedString())
                .font(.regular(18))
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(Color.Blue.LIGHT_BLUE)
        .cornerRadius(26)
    }
}

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
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(.allCorners, 9)
        }
    }
}

#Preview {
    HomeScreenView()
}
