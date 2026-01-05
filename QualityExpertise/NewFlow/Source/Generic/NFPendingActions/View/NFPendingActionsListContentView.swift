//
//  NFPendingActionsListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct NFPendingActionsListContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = NFPendingActionsListViewModel()
    @State var pendingActionTypes: [NFPendingActionType] = []
    var contentId: Int = -1
    let updateListPublisher = NotificationCenter.default.publisher(for: .UPDATE_PENDINGACTION)
    @State var pendingActions: [NFPendingActionDetails] = []
    @State var myPendingActions = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                if viewModel.isLoading {
                    VStack {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                } else if let error = viewModel.error {
                    VStack {
                        error.viewRetry(isError: true) {
                            viewModel.onRetry()
                        }
                    }
                } else if viewModel.noDataFound || (pendingActionTypes.count > 0 && viewModel.filterPendingActions == []) {
                    VStack {
                        "no_pending_actions_found".localizedString()
                            .viewRetry {
                                viewModel.onRetry()
                            }
                    }
                } else {
                    VStack {
                        HStack {
                            Text("pending_action_label".localizedString())
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(13))
                            
                            Spacer()
                            
                            Button {
                                myPendingActions.toggle()
                                if myPendingActions {
                                    if pendingActionTypes.count > 0 {
                                        for pendingAction in viewModel.filterPendingActions {
                                            if !(pendingAction.isUserSpecific ?? false) {
                                                viewModel.filterPendingActions.remove(at: viewModel.filterPendingActions.firstIndex(where: { $0.id == pendingAction.id }) ?? -1)
                                                
                                            }
                                        }
                                    } else {
                                        for pendingAction in viewModel.pendingActions {
                                            if pendingAction.isUserSpecific ?? false {
                                                viewModel.filterPendingActions.append(pendingAction)
                                                
                                            }
                                        }
                                        if viewModel.filterPendingActions == [] {
                                            viewModel.noDataFound = true
                                            myPendingActions = false
                                        }
                                    }
                                } else {
                                    var tempPendingActions: [NFPendingActionDetails] = []
                                    if pendingActionTypes.count > 0 {
                                        for pendingAction in viewModel.pendingActions {
                                            if pendingActionTypes.contains(pendingAction.type) {
                                                tempPendingActions.append(pendingAction)
                                            }
                                        }
                                        viewModel.filterPendingActions = tempPendingActions
                                        if viewModel.filterPendingActions == [] {
                                            viewModel.noDataFound = true
                                        }
                                    } else {
                                        viewModel.filterPendingActions = []
                                    }
                                }
                            } label: {
                                Image(myPendingActions ? IC.ACTIONS.MY_PENDING_ACTION : IC.ACTIONS.ALL_PENDING_ACTION)
                            }
                        }
                        .padding(.top, 15)
                        .padding(.horizontal, 27.5)
                        
                        ScrollView {
                            VStack {
                                ForEach(viewModel.filterPendingActions.count > 0 ? viewModel.filterPendingActions : viewModel.pendingActions, id: \.id) { pendingAction in
                                    if let index = viewModel.filterPendingActions.count > 0 ? viewModel.filterPendingActions.firstIndex {$0.id == pendingAction.id} : viewModel.pendingActions.firstIndex {$0.id == pendingAction.id} {
                                        if (index.isMultiple(of: 4)) && index != 0 {
                                            if viewModel.addTrackingAuthStatus != .notDetermined {
                                                GADBannerViewController()
                                                    .frame(height: 60)
                                            }
                                        }
                                    }
                                    NFPendingActionRowView(viewModel: .init(pendingActionDetails: pendingAction), isEditable: pendingAction.isEditable)
                                        .onTapGesture {
                                            if pendingAction.isEditable {
                                                viewControllerHolder?.present(style: .overCurrentContext) {
                                                    NFActionsContentView(pendingAction: .constant(pendingAction), isEditable: pendingAction.isEditable)
                                                        .localize()
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 27.5)
                            .padding(.vertical, 25.5)
                        }
                    }
                }
                
            }
            .navigationBarTitle("pending_action".localizedString(), displayMode: .inline)
            .onAppear(perform: {
                viewModel.fetchPendingActionsList { completed in
                    if let pendingAction = viewModel.pendingActions.first(where: {$0.id == contentId}) {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            NFActionsContentView(pendingAction: .constant(pendingAction), isEditable: pendingAction.isEditable)
                                .localize()
                        }
                    }
                }
            })
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            NFFilterContentView(pendingActionTypes: $pendingActionTypes, allPendingActions: viewModel.pendingActions, pendingActions: $viewModel.filterPendingActions, myPendingAction: $myPendingActions)
                                .localize()
                        }
                    } label: {
                        ZStack {
                            Image(IC.ACTIONS.FILTER)
                            
                            if pendingActionTypes.count > 0 {
                                Text(pendingActionTypes.count.string)
                                    .padding(6)
                                    .background(Color.Blue.THEME)
                                    .clipShape(Circle())
                                    .foregroundColor(Color.white)
                                    .font(.regular(12))
                                    .offset(x: -7, y: -12)
                                
                            }
                        }
                    }
                }
            }
            .listenToAppNotificationClicks()
            .onReceive(updateListPublisher, perform: { (output) in
                viewModel.fetchPendingActionsList { completed in
                    
                }
            })
        }
    }
}

struct NFPendingActionsListContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFPendingActionsListContentView()
    }
}
