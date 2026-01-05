//
//  ActionsContentView.swift
// ALNASR
//
//  Created by developer on 02/03/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ActionsContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = ActionsViewModel()
    @State var selectedItem: PendingActionType = .openObservation
    @Binding var pendingAction: PendingActionDetails
    @State var isEditable: Bool
    @State var viewJustification: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    NotificationCenter.default.post(name: .UPDATE_PENDINGACTION, object: nil)
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            
            VStack {
                Spacer()
                
                VStack {
                    if pendingAction.type == .openObservation {
                        openObservationView
                            .padding(.horizontal, 27)
                            .padding(.bottom, 20)
                    } else if pendingAction.type == .requestToJoinGroup {
                        requestToJoinGroupView
                    } else if pendingAction.type == .observationResponsibilityChange || pendingAction.type == .requestToDeleteObservation {
                        responsibilityChangeView
                    } else if pendingAction.type == .reviewObservationCloseOut && !isEditable {
                        openObservationView
                            .padding(.horizontal, 27)
                            .padding(.bottom, 20)
                    } else {
                        reviewObservationCloseOutView
                    }
                }
                .padding(.top, 41)
                .background(Color.white)
                .cornerRadius([.topLeft, .topRight], 25)
            }
            
            VStack {
                if viewModel.isLoading {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                } else if let error = viewModel.error {
                    error.viewRetry {
                        viewModel.onRetry()
                    }
                }
            }
        }
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
        .listenToAppNotificationClicks()
    }
    
    var openObservationView: some View {
        VStack(spacing: 25) {
            LeftAlignedHStack(
                Text("Open Observation")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(17.5))
            )
            
            VStack(spacing: 20) {
                HStack {
                    Text("View Report")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ObservationDetailContentView(viewModel: .init(observationId: pendingAction.contentId))
                    }
                }
                
                HStack {
                    Text("Generate PDF")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                }
                .onTapGesture {
                    generatePdf()
                }
                
                HStack {
                    Text("Close Observation")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        CloseObservationContentView(viewModel: .init(observationId: pendingAction.contentId, observationTitle: "", observationDescription: "", imageDescription: [], groupSpecified: false), isfromPendingAction: true)
                    }
                }
                
                HStack {
                    Text("Request Observation Responsible Person Change")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                }
                .onTapGesture {
                    let DataComponents = pendingAction.groupCode.components(separatedBy: "-")
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ResponsiblePersonChangeContentView(viewModel: .init(groupData: GroupData(groupId: DataComponents.last ?? "", groupCode: pendingAction.groupCode, groupName: "", groupImage: "", userRole: Optional.none, isSelected: false, description: ""), observationId: pendingAction.contentId))
                    }
                }
                
                HStack {
                    Text("Request to Delete Observation")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        DeleteObservationRequestContentView(viewModel: .init(observationId: pendingAction.contentId))
                    }
                }
            }
            
        }
    }
    
    var requestToJoinGroupView: some View {
        VStack(spacing: 25) {
            LeftAlignedHStack(
                Text("Request to Join Group")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(17.5))
            )
                .padding(.horizontal, 27)
                
            
            VStack(spacing: 20) {
                HStack {
                    Text("View Profile")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        GroupMemberProfileContentView(viewModel: .init(userId: pendingAction.userId))
                    }
                }
                
                HStack {
                    Text("View Group")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                }
                .onTapGesture {
                    let DataComponents = pendingAction.groupCode.components(separatedBy: "-")
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        GroupDetailsContentView(viewModel: .init(groupId: DataComponents.last ?? "", groupCode: pendingAction.groupCode))
                    }
                }
            }
            .padding(.horizontal, 27)
            
            approveOrCloseButtonView
        }
    }
    
    var responsibilityChangeView: some View {
        VStack(spacing: 25) {
            HStack {
                Text(pendingAction.type == .observationResponsibilityChange ? "Observation Responsibility Change" : "Request To Delete Observation")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(17.5))
                
                Spacer()
                
                if viewJustification {
                    Text("Back")
                        .foregroundColor(Color.Blue.THEME)
                        .font(.regular(12))
                        .onTapGesture {
                            viewJustification.toggle()
                        }
                }
            }
            .padding(.horizontal, 27)
                
            
            VStack(spacing: 20) {
                if viewJustification {
                    LeftAlignedHStack(
                        Text("Justification")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                    )
                    
                    LeftAlignedHStack(
                        Text(pendingAction.justification ?? "NA")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.regular(12))
                    )
                    
                } else {
                    HStack {
                        Text("View Observation")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                        
                        Spacer()
                        
                        Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                    }
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            ObservationDetailContentView(viewModel: .init(observationId: pendingAction.contentId))
                        }
                    }
                    
                    HStack {
                        Text("View Justification")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                        
                        Spacer()
                        
                        Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                    }
                    .onTapGesture {
                        viewJustification.toggle()
                    }
                }
            }
            .padding(.horizontal, 27)
            
            approveOrCloseButtonView
        }
    }
    
    var reviewObservationCloseOutView: some View {
        VStack(spacing: 25) {
            if isEditable {
                LeftAlignedHStack(
                    Text("Review Observation Closeout")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(17.5))
                )
                    .padding(.horizontal, 27)
                    
                
                VStack(spacing: 20) {
                    HStack {
                        Text("View observation Closeout")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                        
                        Spacer()
                        
                        Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                    }
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            ObservationDetailContentView(viewModel: .init(observationId: pendingAction.contentId))
                        }
                    }
                }
                .padding(.horizontal, 27)
                
                approveOrCloseButtonView
            }
            
        }
    }
    
    var approveOrCloseButtonView: some View {
        HStack {
            Button {
                approveOrRejected(actionType: .rejected)
            } label: {
                Text("Reject")
                    .foregroundColor(Color.Grey.SLATE)
                    .font(.regular(16.2))
                    .frame(maxWidth: .infinity, minHeight: 85)
            }
            
            Divider()
                .frame(width: 1, height: 37, alignment: .center)
                .foregroundColor(Color.Silver.TWO)
            
            Button {
                approveOrRejected(actionType: .approved)
            } label: {
                Text("Approve")
                    .foregroundColor(Color.Blue.THEME)
                    .font(.regular(16.2))
                    .frame(maxWidth: .infinity, minHeight: 85)
            }
        }
        .background(Color.white)
        .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
    }
    
    func generatePdf() {
        viewModel.generatePdf(observationId: pendingAction.contentId) { completed in
            savePdf(urlString: viewModel.pdfUrl)
        }
    }
    
    func approveOrRejected(actionType: ActionType) {
        viewModel.approveOrReject(id: pendingAction.id, actionType: actionType) { completed in
            NotificationCenter.default.post(name: .UPDATE_PENDINGACTION, object: nil)
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
    
    func savePdf(urlString:String) {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let pdfNameFromUrl = "ALNASR- \(Date().millisecondsSince1970).pdf"
        let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
        do {
            try pdfData?.write(to: actualPath, options: .atomic)
            viewModel.toast = "pdf successfully saved!".successToast
        } catch {
            viewModel.toast = Toast.alert(subTitle: "Pdf could not be saved")
        }
    }
}

