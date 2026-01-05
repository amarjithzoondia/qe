//
//  DraftObservationListContentView.swift
// QualityExpertise
//
//  Created by developer on 16/02/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct DraftObservationListContentView: View {
    @StateObject var viewModel = DraftObservationListViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var minusButtonTapped: Bool = false
    @State var dbId: Int = 0
    let updateDraftPublisher = NotificationCenter.default.publisher(for: .UPDATE_DRAFT)
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.observations.count <= 0 {
                        "no_observations_found".localizedString()
                            .viewRetry {
                            viewModel.onRetry()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.observations.reversed(), id: \.id) { (observation) in
                                    DraftObservationListRowView(minusButtonTapped: $minusButtonTapped, dbId: $dbId, observation: .constant(observation))
                                        .onTapGesture {
                                            viewControllerHolder?.present(style: .overCurrentContext) {
                                                CreateObservationContentView(viewModel: .init(isEditing: true), draftObservation: .constant(observation))
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
            .onAppear(perform: {
                viewModel.observations = UserManager.getObservationDraftList()
            })
            .onReceive(updateDraftPublisher, perform: { (output) in
                viewModel.observations = []
                viewModel.observations = UserManager.getObservationDraftList()
            })
            .navigationBarTitle("observations".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: $minusButtonTapped, title: "delete_draft".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("delete_draft_confirmation".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        minusButtonTapped.toggle()
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
                        let index = viewModel.observations.firstIndex(where: {$0.id == dbId})
                        viewModel.observations.remove(at: index ?? -1)
                        UserDefaults.standard.removeObject(forKey: UserManager.OBSERVATION_DRAFT)
                        UserManager.saveObservationDraftData(datas: viewModel.observations)
                        minusButtonTapped.toggle()
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
}

struct DraftObservationListContentView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListContentView()
    }
}

