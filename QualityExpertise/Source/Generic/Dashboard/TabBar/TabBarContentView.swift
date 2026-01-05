//
//  TabBarContentView.swift
// ALNASR
//
//  Created by developer on 26/01/22.
//

import SwiftUI

struct TabBarContentView: View {
    @State private var notificationRefreshID = UUID()
    @State var selectedTab = 0
    var image: String!
    @StateObject private var userManager = UserManager.shared
    let updateCountPublisher = NotificationCenter.default.publisher(for: .UPDATE_COUNT)
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        
        ZStack {
            TabView(selection: $selectedTab) {
                Group {
                    TabBarContainerView(content: DashboardContentView().localize(), contentVisible: true)
                        .tabItem {
                            if let image = selectedTab == TabItem.dashboard.rawValue ? TabItem.dashboard.selectedImage : TabItem.dashboard.image {
                                Image(image)
                            }
                        }
                        .tag(TabItem.dashboard.rawValue)
                    
                    TabBarContainerView(content: ProjectListContentView().localize(), contentVisible: true)
                        .tabItem {
                            if let image = selectedTab == TabItem.projects.rawValue ? TabItem.projects.selectedImage : TabItem.projects.image {
                                Image(image)
                            }
                        }
                        .tag(TabItem.projects.rawValue)
                        
                    Spacer()
                    
                    TabBarContainerView(content: NotificationListContentView().localize(), contentVisible: true)
                        .id(notificationRefreshID)
                        .onTapGesture {
                                    notificationRefreshID = UUID() // forces reload
                                }
                        .tabItem {
                            if let image = selectedTab == TabItem.notifications.rawValue ? (userManager.notificationUnReadCount <= 0 ? TabItem.notifications.selectedImage : IC.DASHBOARD.TAB.NOTIFICATION_SELECTED_UNREAD) : (userManager.notificationUnReadCount <= 0 ? TabItem.notifications.image : IC.DASHBOARD.TAB.NOTIFICATION_UNREAD) {
                                Image(image)
                            }
                            
                        }
                        .tag(TabItem.notifications.rawValue)
                        
                    
                    TabBarContainerView(content: MoreMenuContentView(isFromTabbar: true).localize(), contentVisible: true)
                        .tabItem {
                            if let image = selectedTab == TabItem.menu.rawValue ? TabItem.menu.selectedImage : TabItem.menu.image {
                                Image(image)
                            }
                        }
                        .tag(TabItem.menu.rawValue)
                }
            }
            
            VStack {
                Spacer()
                
                LogoTabItemView()
                    .padding(.bottom, 23.5)
                    .padding(.leading, 13)
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            ContactUsContentView()
                                .localize()
                        }
                    }
            }
            .ignoresSafeArea(.keyboard)
        }
        .onReceive(updateCountPublisher) { (output) in
//            self.pendingActionsCount = UserManager.instance.pendingActionsCount
//            self.notificationUnReadCount = UserManager.instance.notificationUnReadCount
        }

    }
    
//    func switchToSearchTab() {
//        if selectedTab != TabItem.search.rawValue {
//            selectedTab = TabItem.search.rawValue
//        }
//    }
}

struct TabBarContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarContentView()
    }
}

extension UITabBarController {
    open override func viewWillLayoutSubviews() {
        let array = self.viewControllers
        for controller in array! {
            controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 6, bottom: -6, right: -6)
        }
    }
}

struct ComingSoonView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
//    @Environment(\.rootPresentationMode) private var rootPresentationMode: Binding<RootPresentationMode>
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                Text("Coming Soon")
                    .font(.regular(16))
                    .foregroundColor(Color.Indigo.DARK)
                    .onTapGesture {
                        
                    }
            }
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.present(style: .overFullScreen) {
                        TabBarContentView(selectedTab: 0)
                            .localize()
                    }
                }
            })
        }
        
    }
}

