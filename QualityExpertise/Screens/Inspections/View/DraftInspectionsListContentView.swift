//
//  DraftInspectionsListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct DraftInspectionsListContentView: View {
    @StateObject private var viewModel = DraftInspectionsListViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    private let updateDraftPublisher = NotificationCenter.default.publisher(for: .UPDATE_DRAFT)
    @State private var deleteInspection: Inspections?
    let onNewInspectionAdded: (() -> ())?

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                inspectionList
                
                if viewModel.isLoading {
                    Color.white.opacity(0.25)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .onAppear {
                viewModel.fetchDraftList()
            }
            .onReceive(updateDraftPublisher, perform: { (output) in
                viewModel.fetchDraftList()
            })
            .navigationBarTitle("inspections_draft".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: .constant(deleteInspection != nil), title: "delete_draft".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("inspections_draft_delete_message".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        deleteInspection = nil
                    } label: {
                        Text("cancel".localizedString())
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        _ = viewModel.deleteViolation(inspection: deleteInspection!)
                        viewModel.fetchDraftList()
                        deleteInspection = nil
                    } label: {
                        Text("continue".localizedString())
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)
            }
        }
    }
    
    private var inspectionList: some View {
        VStack {
            if viewModel.inspections.count <= 0 {
                "no_inspections_found".localizedString()
                    .viewRetry {
                        viewModel.onRetry()
                    }
                
            } else if let error = viewModel.error {
                error.viewRetry(isError: true) {
                    viewModel.fetchDraftList()
                }
                
                Spacer()
                
            }  else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.inspections.reversed(), id: \.id) { inspections in
                            DraftInspectionsListRowView(
                                inspection: inspections,
                                minusButtonTapped: {
                                    deleteInspection = inspections
                                }
                            )
                            .onTapGesture {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    CreateEquipmentStaticView(
                                        viewModel: .init(
                                            inspectionID: nil,
                                            inspection: nil,
                                            draftInspection: inspections,
                                            inspectionTypeID: inspections.auditItem.auditItemId),
                                        isListChanged: .constant(false),
                                        inspectionType: inspections.auditItem
                                    )
                                    .localize()
                                }
                            }
                        }
                    }
                    .padding(.top, 15.5)
                    .padding(.horizontal, 27)
                }
            }
        }
    }
}

struct DraftInspectionListContentView_Previews: PreviewProvider {
    static var previews: some View {
        DraftInspectionsListContentView(onNewInspectionAdded: nil)
    }
}

