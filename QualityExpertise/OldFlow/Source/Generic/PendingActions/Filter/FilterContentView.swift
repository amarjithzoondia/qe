//
//  FilterContentView.swift
// ALNASR
//
//  Created by developer on 02/03/22.
//

import SwiftUI

struct FilterContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Binding var pendingActionTypes: [PendingActionType]
    @State var tempPendingActionTypes: [PendingActionType] = []
    @State var allPendingActions: [PendingActionDetails] = []
    @Binding var pendingActions: [PendingActionDetails]
    @Binding var myPendingAction: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    pendingActionTypes = tempPendingActionTypes
                    if pendingActionTypes.count > 0 {
                        for pendingAction in allPendingActions {
                            if pendingActionTypes.contains(pendingAction.type) {
                                if myPendingAction {
                                    if pendingAction.isUserSpecific ?? false {
                                        pendingActions.append(pendingAction)
                                    }
                                } else {
                                    pendingActions.append(pendingAction)
                                }
                            }
                        }
                    }
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 25) {
                    LeftAlignedHStack(
                        Text("Filter")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(17.5))
                    )
                        .padding(.horizontal, 27.5)
                    
                    VStack(spacing: 15) {
                        ForEach(PendingActionType.allCases, id: \.self) { pendingActionType in
                            HStack {
                                Text(pendingActionType.description)
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.regular(14))
                                
                                Spacer()
                                
                                Image(tempPendingActionTypes.contains(pendingActionType) ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            }
                            .onTapGesture {
                                if tempPendingActionTypes.contains(pendingActionType) {
                                    if let index = tempPendingActionTypes.firstIndex(where: { $0 == pendingActionType }) {
                                        tempPendingActionTypes.remove(at: index)
                                    }
                                } else {
                                    tempPendingActionTypes.append(pendingActionType)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 27.5)
                    
                    HStack {
                        Button {
                            viewControllerHolder?.dismiss(animated: true, completion: nil)
                        } label: {
                            Text("Close")
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(16.2))
                                .frame(maxWidth: .infinity, minHeight: 85)
                        }
                        
                        Divider()
                            .frame(width: 1, height: 37, alignment: .center)
                            .foregroundColor(Color.Silver.TWO)
                        
                        Button {
                            pendingActionTypes = tempPendingActionTypes
                            if pendingActionTypes.count > 0 {
                                for pendingAction in allPendingActions {
                                    if pendingActionTypes.contains(pendingAction.type) {
                                        if myPendingAction {
                                            if pendingAction.isUserSpecific ?? false {
                                                pendingActions.append(pendingAction)
                                            }
                                        } else {
                                            pendingActions.append(pendingAction)
                                        }
                                    }
                                }
                            }
                            viewControllerHolder?.dismiss(animated: true, completion: nil)
                        } label: {
                            Text("Apply")
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(16.2))
                                .frame(maxWidth: .infinity, minHeight: 85)
                        }
                    }
                    .background(Color.white)
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                }
                .padding(.top, 41)
                .background(Color.white)
                .cornerRadius([.topLeft, .topRight], 25)
            }
        }
        .onAppear {
            tempPendingActionTypes = pendingActionTypes
            pendingActions = []
        }
        .listenToAppNotificationClicks()
    }
}

struct FilterContentView_Previews: PreviewProvider {
    static var previews: some View {
        FilterContentView(pendingActionTypes: .constant([]), pendingActions: .constant([]), myPendingAction: .constant(false))
    }
}
