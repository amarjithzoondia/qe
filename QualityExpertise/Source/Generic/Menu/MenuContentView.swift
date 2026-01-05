//
//  MenuContentView.swift
// QualityExpertise
//
//  Created by developer on 31/01/22.
//

import SwiftUI


struct MoreMenuContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.layoutDirection) private var layoutDirection
    @State var relaunchApp = false
    @State var showLogoutAlert = false
    @State var showMyProfile = false
    @StateObject var viewModel = MenuViewModel()
    var isFromTabbar: Bool = false
    let updatePublisher = NotificationCenter.default.publisher(for: .UPDATE_PROFILE)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            if !(UserManager.getCheckOutUser()?.isGuestUser ?? false) {
                                LeftAlignedHStack(
                                    MenuProfileView(user: $viewModel.user)
                                )
                                
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.Grey.LIGHT_PERIWINKLE)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 21)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    MoreMenuView(menu: .aboutUs)
                                        .onTapGesture {
//                                            viewControllerHolder?.present(style: .overCurrentContext) {
//                                                AboutUsContentView()
//                                            }
                                            if let url = URL(string: "https://qe.zoondia.org/about-us") {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                    MoreMenuView(menu: .contactUs)
                                        .onTapGesture {
                                            viewControllerHolder?.present(style: .overCurrentContext) {
                                                ContactUsContentView()
                                                    .localize()
                                            }
                                        }
                                    
                                    if !(UserManager.getCheckOutUser()?.isGuestUser ?? false) {
                                        MoreMenuView(menu: .settings)
                                            .onTapGesture {
                                                viewControllerHolder?.present(style: .overCurrentContext) {
                                                    SettingsContentView(isFromDashboard: false)
                                                        .localize()
                                                }
                                            }
                                    }
                                    
                                    MoreMenuView(menu: .termsOfUse)
                                        .onTapGesture {
                                            viewControllerHolder?.present(style: .overCurrentContext) {
                                                TermsofUseContentView()
                                                    .localize()
                                            }
                                        }
                                    MoreMenuView(menu: .privacyPolicy)
                                        .onTapGesture {
                                            viewControllerHolder?.present(style: .overCurrentContext) {
                                                PrivacyPolicyContentView()
                                                    .localize()
                                            }
                                        }
                                }
                                .padding(.top, 31.5)
                                
                                Spacer()
                            }
                            
                            if !(UserManager.getCheckOutUser()?.isGuestUser ?? false) {
                                logoutButtonView
                                
                                if let versionString = Configurations.versionString {
                                    Text(versionString)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color.Indigo.DARK)
                                        .font(.light(12))
                                        .padding(.bottom, 24)
                                }
                            }
                        }
                        .padding(.bottom, 70)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitle("menu".localizedString(), displayMode: .inline)
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .onReceive(updatePublisher, perform: { (user) in
                viewModel.user = UserManager().user
            })
            .alert(isPresented: $showLogoutAlert) {
                Alert(title: Text("logout_confirmation".localizedString()),
                      primaryButton: .destructive(Text("yes".localizedString())) {
                            onLogoutConfirmation()
                        },
                      secondaryButton: .cancel(Text("cancel".localizedString())))
            }
            .listenToAppNotificationClicks()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isFromTabbar {
                        Button(action: {
                            if UserManager.getCheckOutUser()?.isGuestUser ?? false {
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            } else {
                                viewControllerHolder?.present(style: .overFullScreen) {
                                    CustomTabBarContentView(selectedTab: .dashboard)
                                        .localize()
                                }
                            }
                        }) {
                            Image(IC.INDICATORS.BLACK_BACKWARD_ARROW)
                                .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                        }
                    }
                }
            }
        }
    }
    
    var logoutButtonView: some View {
        ButtonWithLoader(action: { onLogout() },
                         title: "logout".localizedString(),
                         width: screenWidth - (28 * 2),
                         height: 41,
                         isLoading: $viewModel.isActionsLoading)
            .padding(.top, 52)
            .padding(.bottom, 30)
    }
    
    func onLogout() {
        showLogoutAlert.toggle()
    }
    
    func onLogoutConfirmation() {
        viewModel.logoutUser {}
    }
}

extension MoreMenuContentView {
    struct MenuProfileView: View {
        @Environment(\.viewController) private var viewControllerHolder: UIViewController?
        @Binding var user: User?
        
        var body: some View {
            HStack(spacing: 21) {
                HStack(spacing: 21) {
                    WebUrlImage(url: user?.profileImage?.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                        .frame(width: 72, height: 72)
                        .cornerRadius(72/2)
                        .onTapGesture {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                ProfileContentView(viewModel: .init())
                                    .localize()
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(user?.name ?? "")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(17))
                        
                        Text(user?.email ?? "")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(13))
                        
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                ProfileContentView(viewModel: .init())
                                    .localize()
                            }
                        } label: {
                            Text("view_profile".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        }

                    }
                    
                    Spacer()
                }
                .padding(.top, 11)
                .padding(.horizontal, 30)
            }
        }
    }
        
    struct MoreMenuView: View {
        var menu: MoreMenu
        
        var body: some View {
            HStack(spacing: 21) {
                Image(menu.icon)
                    .resizable()
                    .frame(width: 18, height: 16.5)
                
                Text(menu.title)
                    .font(.regular(13))
                    .foregroundColor(Color.Indigo.DARK)
                
                Spacer()
            }
            .padding(.horizontal, 34.5)
            .padding(.vertical, 33/2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MoreMenuContentView()
    }
}
