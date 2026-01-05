//
//  ActionsContentView.swift
// ALNASR
//
//  Created by developer on 02/03/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ActionsContentView: View {
    @Environment(\.layoutDirection) private var layoutDirection
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
                    error.viewRetry(isError: true) {
                        viewModel.onRetry()
                    }
                }
            }
        }
        .overlay(
            Group {
                if viewModel.pdfLoading {
                    PDFLoadingOverlay()
                }
            }
        )
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
        .listenToAppNotificationClicks()
    }
    
    var openObservationView: some View {
        VStack(spacing: 25) {
            LeftAlignedHStack(
                Text("open_observation".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(17.5))
            )
            
            VStack(spacing: 20) {
                HStack {
                    Text("view_report".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ObservationDetailContentView(viewModel: .init(observationId: pendingAction.contentId))
                            .localize()
                    }
                }
                
                HStack {
                    Text("generate_pdf".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                }
                .onTapGesture {
                    generatePdf()
                }
                
                HStack {
                    Text("close_observation".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        CloseObservationContentView(viewModel: .init(observationId: pendingAction.contentId, observationTitle: "", observationDescription: "", imageDescription: [], groupSpecified: false), isfromPendingAction: true)
                            .localize()
                    }
                }
                
                HStack {
                    Text("request_responsibility_change".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                }
                .onTapGesture {
                    let DataComponents = pendingAction.groupCode.components(separatedBy: "-")
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ResponsiblePersonChangeContentView(viewModel: .init(groupData: GroupData(groupId: DataComponents.last ?? "", groupCode: pendingAction.groupCode, groupName: "", groupImage: "", userRole: Optional.none, isSelected: false, description: ""), observationId: pendingAction.contentId))
                            .localize()
                    }
                }
                
                HStack {
                    Text("request_delete_observation".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        DeleteObservationRequestContentView(viewModel: .init(observationId: pendingAction.contentId))
                            .localize()
                    }
                }
            }
            
        }
    }
    
    var requestToJoinGroupView: some View {
        VStack(spacing: 25) {
            LeftAlignedHStack(
                Text("request_to_join_group".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(17.5))
            )
                .padding(.horizontal, 27)
                
            
            VStack(spacing: 20) {
                HStack {
                    Text("view_profile".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                }
                .onTapGesture {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        GroupMemberProfileContentView(viewModel: .init(userId: pendingAction.userId))
                            .localize()
                    }
                }
                
                HStack {
                    Text("view_group".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                    
                    Spacer()
                    
                    Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                }
                .onTapGesture {
                    let DataComponents = pendingAction.groupCode.components(separatedBy: "-")
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        GroupDetailsContentView(viewModel: .init(groupId: DataComponents.last ?? "", groupCode: pendingAction.groupCode))
                            .localize()
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
                Text(pendingAction.type == .observationResponsibilityChange ? "observation_responsibility_change".localizedString() : "request_to_delete_observation".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(17.5))
                
                Spacer()
                
                if viewJustification {
                    Text("back".localizedString())
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
                        Text("justification".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                    )
                    
                    LeftAlignedHStack(
                        Text(pendingAction.justification ?? "na".localizedString())
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.regular(12))
                    )
                    
                } else {
                    HStack {
                        Text("view_observation".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                        
                        Spacer()
                        
                        Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                            .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                    }
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            ObservationDetailContentView(viewModel: .init(observationId: pendingAction.contentId))
                                .localize()
                        }
                    }
                    
                    HStack {
                        Text("view_justification".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                        
                        Spacer()
                        
                        Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                            .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
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
                    Text("review_observation_closeout".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(17.5))
                )
                    .padding(.horizontal, 27)
                    
                
                VStack(spacing: 20) {
                    HStack {
                        Text("review_observation_closeout".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                        
                        Spacer()
                        
                        Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                            .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                    }
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            ObservationDetailContentView(viewModel: .init(observationId: pendingAction.contentId))
                                .localize()
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
                Text("reject".localizedString())
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
                Text("approve".localizedString())
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
            Task {
                await savePdf(urlString: viewModel.pdfUrl)
            }
        }
    }
    
    func approveOrRejected(actionType: ActionType) {
        viewModel.approveOrReject(id: pendingAction.id, actionType: actionType) { completed in
            NotificationCenter.default.post(name: .UPDATE_PENDINGACTION, object: nil)
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
    
    func savePdf(urlString: String) async {
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let resourceDocPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pdfNameFromUrl = "ALNASR - Observations(\(pendingAction.contentId)).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)

            try data.write(to: actualPath, options: .atomic)

            await MainActor.run {
                viewModel.pdfLoading = false
                viewModel.toast = "pdf_saved_success".localizedString().successToast
            }
        } catch {
            await MainActor.run {
                viewModel.pdfLoading = false
                viewModel.toast = Toast.alert(subTitle: "pdf_save_failed".localizedString())
            }
        }
    }

}

