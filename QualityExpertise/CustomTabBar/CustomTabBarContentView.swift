
//
//  CustomNFTabBarContentView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 14/11/25.
//

import SwiftUI

struct CustomTabBarContentView: View {
    
    @State var selectedTab: CustomTab = .dashboard
    @StateObject private var userManager = UserManager.shared
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?

    var body: some View {
        ZStack {
            // MARK: - Switch Views
            TabView(selection: $selectedTab) {
                DashboardContentView().localize()
                    .tag(CustomTab.dashboard)
                
                ProjectListContentView().localize()
                    .tag(CustomTab.projects)
                
                NotificationListContentView().localize()
                    .tag(CustomTab.notifications)
                
                MoreMenuContentView(isFromTabbar: true).localize()
                    .tag(CustomTab.menu)
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

extension CustomTabBarContentView {
    private var customTabBar: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 6, y: -2)
                .frame(height: 70)
                
            HStack(spacing: 50) {
                
                tabButton(.dashboard,
                          image: TabItem.dashboard.image ?? "",
                          selectedImage: TabItem.dashboard.selectedImage ?? "")
                
                tabButton(.projects,
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


extension CustomTabBarContentView {
    private func tabButton(_ tab: CustomTab,
                           image: String,
                           selectedImage: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Group {
                if tab == .notifications {
                    // Use special icon logic
                    Image(notificationIcon(isSelected: selectedTab == .notifications))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                } else {
                    // Default icon logic
                    Image(selectedTab == tab ? selectedImage : image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
        }
    }

    
    private func notificationIcon(isSelected: Bool) -> String {
        let hasUnread = userManager.notificationUnReadCount > 0
        
        if isSelected {
            return hasUnread
            ? IC.DASHBOARD.TAB.NOTIFICATION_SELECTED_UNREAD
            : (TabItem.notifications.selectedImage ?? "")
        } else {
            return hasUnread
            ? IC.DASHBOARD.TAB.NOTIFICATION_UNREAD
            : (TabItem.notifications.image ?? "")
        }
    }

}

