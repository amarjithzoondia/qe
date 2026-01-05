//@Environment(\.viewController) private var viewControllerHolder: UIViewController?
//  CloseObservationDetailPageContentView.swift
// ALNASR
//
//  Created by developer on 24/02/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct CloseObservationContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: CloseObservationViewModel
    @State private var closeOutDescription: String = Constants.EMPTY_STRING
    @State var imageDescription: [ImageData] = [ImageData.dummy(imageCount: 1)]
    @State var imageCount: Int = 1
    @State var isfromPendingAction: Bool = false
    @State var imageListId = UUID()
    @State private var showObservationImage = false
    @State var showImage: Bool = false
    @State var imageData: String?
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if let error = viewModel.error {
                        error.viewRetry {
                            viewModel.onRetry()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    LeftAlignedHStack(
                                        Text(viewModel.observationTitle ?? "")
                                            .foregroundColor(Color.Indigo.DARK)
                                            .font(.semiBold(19))
                                    )
                                        .padding(.leading, 23.5)
                                        .padding(.top, 24.5)
                                    
                                    if viewModel.observationDescription != "" {
                                        LeftAlignedHStack(
                                            Text(viewModel.observationDescription ?? "NA")
                                                .foregroundColor(Color.Blue.BLUE_GREY)
                                                .font(.light(12))
                                        )
                                        .padding(.top, 15)
                                        .padding(.leading, 23.5)
                                        .padding(.bottom, viewModel.groupSpecified ? 0.0 : 23.5)
                                    } else {
                                        LeftAlignedHStack(
                                            Text("NA")
                                                .foregroundColor(Color.Blue.BLUE_GREY)
                                                .font(.light(12))
                                                .padding(.trailing, viewModel.groupSpecified ? 0.0 : 23.5)
                                        )
                                        .padding(.top, 15)
                                        .padding(.leading, 23.5)
                                        .padding(.bottom, viewModel.groupSpecified ? 0.0 : 23.5)
                                    }
                                    
                                    if viewModel.groupSpecified {
                                        groupView
                                            .padding(.top, 23.5)
                                    }
                                }
                                .background(Color.Grey.PALE)
                                .cornerRadius(10)
                                .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                                
                                if let images = viewModel.images, images != [] {
                                    VStack {
                                        LeftAlignedHStack(
                                            Text("OBSERVATION IMAGES")
                                                .foregroundColor(Color.Blue.GREY)
                                                 .font(.regular(12))
                                        )
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 11) {
                                                ForEach(images, id: \.self) { image in
                                                    WebUrlImage(url: image.url)
                                                        .frame(width: 99, height: 73)
                                                        .cornerRadius(10)
                                                        .onTapGesture {
                                                            imageData = image
                                                            showImage.toggle()
                                                        }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 15.5)
                                }
                                
                                closeOutDescriptionView
                                    .padding(.top, 15.5)
                                
                                imageView
                                    .padding(.top, 13.5)
                                
                                if imageDescription.endIndex < 6 {
                                    Button {
                                        addImages()
                                    } label: {
                                        HStack{
                                            Image(IC.ACTIONS.PLUS)
                                            
                                            Text("Add Image")
                                                .foregroundColor(Color.Blue.THEME)
                                                .font(.regular(12))
                                            
                                            Spacer()
                                        }
                                    }
                                    .padding(.top, 13.5)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 21)
                            .padding(.horizontal, 28.5)
                        }
                    }
                }
                .padding(.bottom, (45 + 30))
                
                VStack {
                    Spacer()
                    
                    Button {
                        closeObservation()
                    } label: {
                        Text("Submit")
                            .foregroundColor(Color.white)
                            .font(.medium(16))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 45)
                    .background(Color.Blue.THEME)
                    .cornerRadius(22.5)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 28.5)
                
                if viewModel.isLoading {
                    Color.white.opacity(0.25)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .navigationBarTitle("Close Observation", displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .onChange(of: imageCount, perform: { (value) in
                let index = imageDescription.endIndex
                imageDescription.append(ImageData.dummy(imageCount: index + 1))
            })
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .onAppear {
                if isfromPendingAction {
                    viewModel.fetchObservationDetails()
                }
            }
            .listenToAppNotificationClicks()
        }
        .imageViewerOverlay(viewerShown: $showImage, images: [imageData ?? ""])
    }
    
    var groupView: some View {
        VStack {
            HStack(spacing: 18) {
                WebUrlImage(url: viewModel.groupImage?.url, placeholderImage: Image(IC.PLACEHOLDER.LOGO))
                    .frame(width: 46.5, height: 46.5)
                    .cornerRadius(23.25)

                VStack {
                    LeftAlignedHStack(
                        Text(viewModel.groupName ?? "")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.medium(13))
                    )
                    
                    LeftAlignedHStack(
                        Text(viewModel.groupCode ?? "")
                            .foregroundColor(Color.Grey.SLATE)
                            .font(.regular(12))
                    )
                }
                
                Spacer()
            }
            .padding(.top, 17.5)
            .padding(.bottom, 14.5)
            .padding(.leading, 20.5)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
    
    var closeOutDescriptionView: some View {
        ThemeTextEditorView(
            text: $closeOutDescription,
            title: "CLOSE OUT DESCRIPTION".localizedString(),
            disabled: false,
            keyboardType: .asciiCapable,
            isMandatoryField: false,
            limit: Constants.Number.Limit.DESCRIPTION,
            placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: true
        )
    }
    
    var imageView: some View {
        VStack {
            LeftAlignedHStack(
                Text("UPLOAD IMAGES")
                    .foregroundColor(Color.Blue.GREY)
                     .font(.regular(12))
            )
            
            ForEach(imageDescription.indices, id: \.self) { index in
                CreateImageView(
                    imageUrlGenerated: { url in
                        imageDescription[index].image = url
                    }, descriptionChanged: { description in
                        imageDescription[index].description = description
                    }, minusButtonTapped: {
                        var images = imageDescription
                        images.remove(at: index)
                        imageDescription = images
                        imageListId = UUID()
                    }, viewModel: CreateImageViewModel(item: imageDescription[index], index: index), showImage: $showImage, imageUrlData: $imageData)
            }
            .id(imageListId)
        }
    }
        
    func closeObservation() {
        viewModel.closeObservation(description: closeOutDescription, imageDescription: imageDescription) {
            NotificationCenter.default.post(name: .CLOSE_OBSERVATION, object: nil)
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
    
    func addImages() {
        if imageDescription.last?.image == "" {
            viewModel.toast = Toast.alert(subTitle: "Please add Image \(imageCount) first.")
        } else {
            imageCount = imageCount + 1
        }
    }
}

struct CloseObservationContentView_Previews: PreviewProvider {
    static var previews: some View {
        CloseObservationContentView(viewModel: .init(observationId: -1, observationTitle: "", observationDescription: "", groupImage: "", groupName: "", groupCode: "", imageDescription: [], groupSpecified: false))
    }
}
