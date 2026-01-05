//
//  DraftPreTaskListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 27/10/25.
//


import SwiftUI
import SwiftfulLoadingIndicators

struct DraftPreTaskListContentView: View {
    @StateObject private var viewModel = DraftPreTaskListViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    private let updateDraftPublisher = NotificationCenter.default.publisher(for: .UPDATE_DRAFT)
    @State private var deletePreTask: PreTask?
    let onNewPreTaskAdded: (() -> ())?

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                preTaskList
                
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
            .navigationBarTitle("pre_task_draft".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: .constant(deletePreTask != nil), title: "delete_draft".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("delete_pre_task_draft".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        deletePreTask = nil
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
                        _ = viewModel.deletePreTask(preTask: deletePreTask!)
                        viewModel.fetchDraftList()
                        deletePreTask = nil
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
    
    private var preTaskList: some View {
        VStack {
            if viewModel.preTasks.count <= 0 {
                "no_pre_task_found".localizedString()
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
                        ForEach(viewModel.preTasks.reversed(), id: \.id) { preTask in
                            DraftPreTaskListRowView(
                                preTask: preTask,
                                minusButtonTapped: {
                                    deletePreTask = preTask
                                }
                            )
                            .onTapGesture {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    CreatePreTaskView(preTask: nil, draftPreTask: preTask) {
                                        viewModel.fetchDraftList()
                                        onNewPreTaskAdded?()
                                    }
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

struct DraftPreTaskListContentView_Previews: PreviewProvider {
    static var previews: some View {
        DraftPreTaskListContentView(onNewPreTaskAdded: nil)
    }
}
