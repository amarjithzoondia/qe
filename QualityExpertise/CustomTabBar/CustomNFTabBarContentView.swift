//
//  CustomNFTabBarContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 14/11/25.
//

import SwiftUI

struct CustomNFTabBarContentView: View {
    @State private var notificationRefreshID = UUID()
    @State private var selectedTab: CustomNFTab = .home
    @StateObject private var userManager = UserManager.shared
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?

    var body: some View {
        ZStack {
            // MARK: - Switch Views
            TabView(selection: $selectedTab) {
                HomeScreenView().localize()
                    .tag(CustomNFTab.home)
                
                NFLocationListContentView().localize()
                    .tag(CustomNFTab.locations)
                
                NFNotificationListContentView().localize()
                    .tag(CustomNFTab.notifications)
                    .id(notificationRefreshID)
                
                MoreMenuContentView(isFromTabbar: true).localize()
                    .tag(CustomNFTab.menu)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Custom Tab Bar
            VStack {
                Spacer()
                customTabBar
            }
        }
        .ignoresSafeArea()
    }
}

extension CustomNFTabBarContentView {
    private var customTabBar: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 6, y: -2)
                .frame(height: 70)
                
            HStack(spacing: 50) {
                
                tabButton(.home,
                          image: TabItem.dashboard.image ?? "",
                          selectedImage: TabItem.dashboard.selectedImage ?? "")
                
                tabButton(.locations,
                          image: TabItem.projects.image ?? "",
                          selectedImage: TabItem.projects.selectedImage ?? "")
                
                Spacer().frame(width: 10)
                
                tabButton(.notifications,
                          image: (userManager.notificationUnReadCount <= 0 ?
                                  TabItem.notifications.image : IC.DASHBOARD.TAB.NOTIFICATION_UNREAD) ?? "",
                          
                          selectedImage: (userManager.notificationUnReadCount <= 0 ?
                                          TabItem.notifications.selectedImage : IC.DASHBOARD.TAB.NOTIFICATION_SELECTED_UNREAD) ?? "")
                
                tabButton(.menu,
                          image: TabItem.menu.image ?? "",
                          selectedImage: TabItem.menu.selectedImage ?? "")
            }
            .padding(.horizontal, 25)
            
            // Center LOGO button (floating)
            LogoTabItemView()
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ContactUsContentView().localize()
                    }
                }
                .offset(y: -32)
        }
        .frame(maxWidth: .infinity)
    }
}


extension CustomNFTabBarContentView {
    private func tabButton(_ tab: CustomNFTab,
                           image: String,
                           selectedImage: String) -> some View {
        
        Button {
            selectedTab = tab
            if tab == .notifications {
                notificationRefreshID = UUID()
            }
        } label: {
            if tab == .notifications {
                Image(notificationIcon(isSelected: selectedTab == .notifications))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            } else {
                Image(selectedTab == tab ? selectedImage : image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        }
    }


    
    private func notificationIcon(isSelected: Bool) -> String {
        let unread = userManager.notificationUnReadCount > 0
        
        if isSelected {
            return unread
            ? IC.DASHBOARD.TAB.NOTIFICATION_SELECTED_UNREAD
            : (TabItem.notifications.selectedImage ?? "")
        } else {
            return unread
            ? IC.DASHBOARD.TAB.NOTIFICATION_UNREAD
            : (TabItem.notifications.image ?? "")
        }
    }

}
