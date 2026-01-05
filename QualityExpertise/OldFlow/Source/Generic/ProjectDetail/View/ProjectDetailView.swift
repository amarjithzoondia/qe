//
//  ProjectDetailView.swift
//  ALNASR
//
//  Created by Amarjith B on 09/04/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ProjectDetailView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: ProjectDetailViewModel
    @State private var imageData: String?
    @State private var showObservationImage: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing:0) {
                    
                    content
                    
                }
            }
            .toolbar {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            }
        }
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
        .imageViewerOverlay(viewerShown: $showObservationImage, images: [imageData ?? ""])
        .onAppear {
            viewModel.fetchProjectDetail()
        }
    }
    
    @ViewBuilder
    private var content : some View {
        if let project = viewModel.projectDetail {
            projectView(project: project)
            
        } else if viewModel.isLoading {
            LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
            
        } else if let error = viewModel.error {
            error.viewRetry {
                viewModel.fetchProjectDetail()
            }
        } else {
            "No Details found".localizedString()
                .viewRetry {
                    viewModel.fetchProjectDetail()
            }
        }
    }
    
    private func projectView(project: Project) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                LeftAlignedHStack(
                    Text(project.name)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(19))
                )
                
                LeftAlignedHStack(
                    Text(project.code)
                        .foregroundColor(Color.Blue.BLUE_GREY)
                        .font(.light(12))
                )
                .padding(.top, 13.5)
                
                clientDetailsView(project: project)
                    .padding(.top, 15.5)
                
                if let description = project.projectDescription {
                    descriptionView(description: description)
                        .padding(.top, 15.5)
                }

                projectImageView(project: project)
                    .padding(.top, 31.5)
                

                locationUrlView(project: project)
                    .padding(.top, 31.5)
                
                Spacer()
            }
            .padding(.top, 15)
            .padding(.bottom, 21)
            .padding(.horizontal, 28.5)
        }
    }
    
    private func clientDetailsView(project: Project) -> some View {
        HStack(spacing: 5) {
            
            Text("Client Name :")
                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                .font(.medium(12))
            
            Text(project.clientName)
                .foregroundColor(Color.Grey.SLATE)
                .font(.regular(12))
            
            Spacer()
        }
    }
    
    private func descriptionView(description: String) -> some View {
        VStack(spacing: 0) {
            LeftAlignedHStack(
                Text("Description")
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.medium(12))
            )
//            .padding(.top, 20.5)
            
            if description.isEmpty {
                LeftAlignedHStack(
                    Text("No Description")
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                        .padding(.top, 13.5)
                )
                    
            } else {
                LeftAlignedHStack(
                    Text(description)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                        .padding(.top, 13.5)
                )
            }
        }
    }
    
    private func projectImageView(project: Project) -> some View {
        VStack(spacing: 20) {
            ImageView(
                ImageUrl: project.image,
                imageData: $imageData,
                showImages: $showObservationImage
            )
            .padding(.top, 5)
        }
    }
    
    private func locationUrlView(project: Project) -> some View {
        VStack(spacing: 12) {
            LeftAlignedHStack(
                Text("Project Location")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13))
            )
            
            LeftAlignedHStack(
                Text(project.location)
                    .foregroundColor(Color.blue)
                    .font(.regular(15))
                    .onTapGesture {
                        if let url = URL(string: project.location) {
                            UIApplication.shared.open(url)
                        }
                    }
            )
        }
    }
}

extension ProjectDetailView {
    struct ImageView: View {
        var ImageUrl: String
        @Binding var imageData: String?
        @Binding var showImages: Bool
        
        var body: some View {
            VStack {
                VStack {
                    LeftAlignedHStack(
                        Text("Image")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.medium(13))
                    )
                    
                    WebUrlImage(url: ImageUrl.url)
                        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 10, x: 1, y: 1)
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 93.5, alignment: .center)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.top, 13.5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            imageData = ImageUrl
                            showImages.toggle()
                        }
                }
                .padding(.vertical, 23.5)
                .padding(.horizontal, 22)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
        }
    }
}

#Preview {
    ProjectDetailView(viewModel: .init(projectID: 1))
}
