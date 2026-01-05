//
//  DraftIncidentListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 11/09/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct DraftIncidentListContentView: View {
    @StateObject private var viewModel = DraftIncidentListViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    private let updateDraftPublisher = NotificationCenter.default.publisher(for: .UPDATE_DRAFT)
    @State private var deleteIncident: Incident?
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
            .navigationBarTitle("incident_drafts", displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: .constant(deleteIncident != nil), title: "delete_draft".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("incident_draft_delete_message".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        deleteIncident = nil
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
                        _ = viewModel.deleteViolation(incident: deleteIncident!)
                        viewModel.fetchDraftList()
                        deleteIncident = nil
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
            if viewModel.incidents.count <= 0 {
                "no_incidents_found".localizedString()
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
                        ForEach(viewModel.incidents.reversed(), id: \.id) { incident in
                            DraftIncidentListRowView(
                                incident: incident,
                                minusButtonTapped: {
                                    deleteIncident = incident
                                }
                            )
                            .onTapGesture {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    CreateIncidentView(
                                        incident: nil,
                                        draftIncident: incident,
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

struct DraftIncidentListContentView_Previews: PreviewProvider {
    static var previews: some View {
        DraftIncidentListContentView(onNewIncidentAdded: nil)
    }
}
