//
//  LocationListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 09/04/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ProjectListContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var searchText = Constants.EMPTY_STRING
    @State var closeButtonActive = false
    @StateObject private var viewModel = ProjectListViewModel()
    var body: some View {
        NavigationView {
            
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    SearchFieldInputView(
                        onEditingChanged: {},
                        onDone: {
                            closeKeyboard()
                            
                        },
                        text: $searchText,
                        placeholder: "search_projects".localizedString(),
                        closeButtonActive: closeButtonActive,
                        foregroundColor: Color.Indigo.DARK,
                        background: Color.white,
                        placeholderColor: Color.Indigo.DARK,
                        onCloseClicked: {
                            
                        }
                    )
                    .onChange(of: searchText) { _ in
                        viewModel.fetchProjects(searchText: searchText)
                    }
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                    .onChange(of: searchText, perform: { value in
                        if searchText == "" {
                            closeButtonActive = false
                        } else {
                            closeButtonActive = true
                        }
                    })
                    .padding(.horizontal, 27)
                    .padding(.top, 10)
                    
                    
                    content
                    
                    Spacer()
                }
                .onAppear {
                    viewModel.fetchProjects(searchText: searchText)
                }
                .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                    viewModel.toast
                }
                .navigationTitle("projects".localizedString())
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.projects.count > 0 {
            projectList
            
        } else if let error = viewModel.error {
            error.viewRetry(isError: true) {
                viewModel.onRetry()
            }
            .verticalCenter()
            
        } else if viewModel.isLoading {
            LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                .verticalCenter()
            
        } else {
            "no_projects_found".localizedString()
                .viewRetry {
                viewModel.onRetry()
            }
                .verticalCenter()
        }
    }
    
    private var projectList: some View {
        ScrollView(.vertical,showsIndicators: false) {
            
            VStack(spacing: 10) {
                
                ForEach(viewModel.projects, id: \.self){ project in
                    ProjectListRowView(viewModel: .init(project: project))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewControllerHolder?.present(style:.overCurrentContext) {
                                ProjectDetailView(viewModel: .init(projectID: project.id))
                                    .localize()
                            }
                        }
                }
            }
            .padding(.top, 15.5)
            .padding(.horizontal, 27)
            .padding(.bottom, (45 + 20))
        }
        .padding(.top, 10)
    }
}
        
    

#Preview {
    ProjectListContentView()
}
