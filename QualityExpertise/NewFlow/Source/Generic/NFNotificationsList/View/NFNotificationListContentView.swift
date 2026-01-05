//
//  NFNotificationListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct NFNotificationListContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = NFNotificationListViewModel()
    var updateList = NotificationCenter.default.publisher(for: .UPDATE_NOTIFICATION_LIST)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isLoading {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    } else if let error = viewModel.error {
                        error.viewRetry(isError: true) {
                            viewModel.onRetry()
                        }
                    } else if viewModel.noDataFound {
                        "no_notifications_found".localizedString()
                            .viewRetry {
                            viewModel.onRetry()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.notifications, id: \.id) { (notification) in
                                    NotificationListRowView(viewModel: .init(notification: notification))
                                        .onTapGesture {
                                            notification.pushType = .notification
                                            NotificationManager.show(notification: notification)
                                        }
                                }
                            }
                            .padding(.vertical, 25)
                        }
                    }
                }
            }
            .navigationBarTitle("notification".localizedString(), displayMode: .inline)
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
            .onReceive(updateList) { (output) in
                viewModel.fetchNotificationList()
            }
        }
    }
}

struct NFNotificationListContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFNotificationListContentView()
    }
}
