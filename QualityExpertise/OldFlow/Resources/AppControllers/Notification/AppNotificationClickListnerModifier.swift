//
//  AppNotificationClickListnerModifier.swift
// ALNASR
//
//  Created by developer on 17/03/22.
//

import SwiftUI

import SwiftUI

struct AppNotificationClickListnerEnvironmentKey: EnvironmentKey {
    static var defaultValue: AppNotification?
}

extension EnvironmentValues {
    var appNotification: AppNotification? {
        get { self[AppNotificationClickListnerEnvironmentKey.self] }
        set { self[AppNotificationClickListnerEnvironmentKey.self] = newValue }
    }
}

struct AppNotificationClickListnerModifier: ViewModifier {
    @State var navigate = false
    let clickPublisher = NotificationCenter.default.publisher(for: .APP_NOTIFICATION_CLICKED)
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: navigate, perform: { newValue in
                if newValue {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        notificationDestinationView(isActive: $navigate)
                            .environment(\.appNotification, NotificationManager.shared.pageToNavigationForNotification)
                            .localize()
                    }
                    
                    navigate = false
                }
            })
            .onReceive(clickPublisher) { (output) in
                let userInfo = output.userInfo
                if userInfo?[Constants.NotificationKey.USER_INFO] as? AppNotification != nil {
                    navigate = notificationDestinationView(isActive: $navigate) != nil
                }
            }
    }
    
    func notificationDestinationView(isActive: Binding<Bool>) -> AnyView? {
        if let notification = NotificationManager.shared.pageToNavigationForNotification {
            if let pushType = notification.pushType {
                switch pushType {
                case .notification:
                    
                    if let listType = notification.typeRaw {
                     switch listType {
                     case .joinGrouprequestAccepted, .groupMemberRoleChanged, .addedToGroup:
                         if let dataComponents = notification.groupCode?.components(separatedBy: "-") {
                             return AnyView(
                                 GroupDetailsContentView(viewModel: .init(groupId: dataComponents.last ?? "", groupCode: notification.groupCode ?? "", notificationId: notification.id))
                             )
                         }
                     case .joinGrouprequestRejected, .removeFromGroup:
                         return AnyView(
                             GroupRequestRejectedPopUpContentView(viewModel: .init(notification: notification))
                         )
                     case .deleteObservationRequestApproved:
                         return AnyView(
                             ObservationListContentView()
                         )
                     case .deleteObservationRequestRejected, .reviewObservationCloseOutApproved, .reviewObservationCloseOutRejected, .reassignresponsiblePersonApproved, .reassignresponsiblePersonRejected, .observationCreated, .observationCreatedToResponsiblePerson, .observationClosedToResponsiblePerson:
                         return AnyView(
                             ObservationDetailContentView(viewModel: .init(observationId: notification.contentId ?? -1, notificationId: notification.id))
                         )
                     case .observationDeleted:
                         return AnyView(
                             ObservationListContentView()
                         )
                     case .general:
                         print("")
                     }
                }
                case .pendingAction:
                    
                    
                    return AnyView(
                        PendingActionsListContentView(contentId: notification.id ?? -1)
                    )
                }
            }
        }
        return nil
    }
}

extension View {
    func listenToAppNotificationClicks() -> some View {
        modifier(AppNotificationClickListnerModifier())
    }
}

