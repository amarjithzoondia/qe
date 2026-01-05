//
//  NFTabBarContentView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI

struct NFTabBarContentView: View {
    
    @State var selectedTab = 0
    var image: String!
    @StateObject private var userManager = UserManager.shared
    let updateCountPublisher = NotificationCenter.default.publisher(for: .UPDATE_COUNT)
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        NavigationView{
            ZStack {
                TabView(selection: $selectedTab) {
                    Group {
                        TabBarContainerView(content: HomeScreenView().localize(), contentVisible: true)
                            .tabItem {
                                if let image = selectedTab == TabItem.dashboard.rawValue ? TabItem.dashboard.selectedImage : TabItem.dashboard.image {
                                    Image(image)
                                }
                            }
                            .tag(TabItem.dashboard.rawValue)
                        
                        TabBarContainerView(content: NFLocationListContentView().localize(), contentVisible: true)
                            .tabItem {
                                if let image = selectedTab == TabItem.projects.rawValue ? TabItem.projects.selectedImage : TabItem.projects.image {
                                    Image(image)
                                }
                            }
                            .tag(TabItem.projects.rawValue)
                        
                        Spacer()
                        
                        TabBarContainerView(content: NFNotificationListContentView().localize(), contentVisible: true)
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
                        .localize()
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
                
            }
        }
        .navigationBarBackButtonHidden()
    }
    
//    func switchToSearchTab() {
//        if selectedTab != TabItem.search.rawValue {
//            selectedTab = TabItem.search.rawValue
//        }
//    }
}

struct NFTabBarContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFTabBarContentView()
    }
}




