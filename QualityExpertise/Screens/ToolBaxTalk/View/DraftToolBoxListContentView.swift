//
//  DraftToolBoxListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 11/09/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct DraftToolBoxListContentView: View {
    @StateObject private var viewModel = DraftToolBoxListViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    private let updateDraftPublisher = NotificationCenter.default.publisher(for: .UPDATE_DRAFT)
    @State private var deleteToolBoxTalk: ToolBoxTalk?
    let onNewIncidentAdded: (() -> ())?

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                violationList
                
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
            .navigationBarTitle("toolbox_talk_drafts".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: .constant(deleteToolBoxTalk != nil), title: "delete_draft".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("toolbox_talk_delete".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        deleteToolBoxTalk = nil
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
                        _ = viewModel.deleteViolation(toolBox: deleteToolBoxTalk!)
                        viewModel.fetchDraftList()
                        deleteToolBoxTalk = nil
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
    
    private var violationList: some View {
        VStack {
            if viewModel.toolBoxTalks.count <= 0 {
                "no_toolbox_talk_found".localizedString()
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
                        ForEach(viewModel.toolBoxTalks.reversed(), id: \.id) { toolBox in
                            DraftToolBoxListRowView(
                                toolBoxTalk: toolBox,
                                minusButtonTapped: {
                                    deleteToolBoxTalk = toolBox
                                }
                            )
                            .onTapGesture {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    CreateToolBoxView(
                                        toolBoxTalk: nil,
                                        draftToolBoxTalk: toolBox,
                                        onSuccess: ({
                                            viewModel.fetchDraftList()
                                            onNewIncidentAdded?()
                                        })
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

struct DraftToolBoxListContentView_Previews: PreviewProvider {
    static var previews: some View {
        DraftToolBoxListContentView(onNewIncidentAdded: nil)
    }
}
