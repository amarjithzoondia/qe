//
//  CreateImageView.swift
// ALNASR
//
//  Created by developer on 07/02/22.
//

import SwiftUI
import PhotosUI
import SwiftUIX
import SwiftfulLoadingIndicators

struct CreateImageView: View {
    var imageUrlGenerated: (_ url: String) -> ()
    var descriptionChanged: (_ description: String) -> ()
    var minusButtonTapped: () -> ()

    @StateObject var viewModel: CreateImageViewModel
    
    @State var title = Constants.EMPTY_STRING
    @State var description = Constants.EMPTY_STRING
    @State var imageCount = 1
    @State var selectedImage: UIImage?
    @State var isImagePickerDisplay = false
    @State var imageUrl = Constants.EMPTY_STRING
    @State var isImagePickFromCamera = false
    @State var isImagePickFromGallery = false
    @State var imageUploadStatus = UploadStatus.pending
    @State var isMinusButtonActive: Bool = false
    @Binding var showImage: Bool
    @Binding var imageUrlData: String?
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Text(viewModel.imageTitleText)
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.medium(13))
                        
                        Spacer()
                        
                        Button {
                            minusButtonTapped()
                        } label: {
                            Image(IC.ACTIONS.MINUS)
                        }
                    }
                    .padding(.top, 23.5)
                    
                    imageView
                        .padding(.top, 13.5)
                    
                    if imageUploadStatus == .inProgress {
                        HStack {
                            Spacer()
                            
                            Text("UPLOAD")
                                .foregroundColor(Color.white)
                                .font(.regular(12))
                                .frame(width: 80, height: 35)
                                .background(Color.Blue.THEME)
                                .cornerRadius(17.5)
                        }
                    }
                    
                    ThemeTextEditorView(text: $description,
                                        title: "DESCRIPTION".localizedString(),
                                        disabled: false,
                                        keyboardType: .asciiCapable,
                                        isMandatoryField: false,
                                        limit: Constants.Number.Limit.Observation.IMAGE_DESCRIPTION,
                                        placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: true
                                    )
                        .onChange(of: description, perform: { newValue in
                            descriptionChanged(newValue)
                        })
                        .padding(.top, 20.5)
                        .padding(.bottom, 39.5)
                }
                .padding(.horizontal, 22)
                
                if imageUploadStatus == .inProgress {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
        .onAppear {
            description = viewModel.item.description
            imageUrl = viewModel.item.image ?? ""
            imageUploadStatus = imageUrl.isEmpty ? .pending : .completed(url: imageUrl)
        }
    }
    
    var imageView: some View {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        return ZStack {
            Button {
                if imageUploadStatus == .pending || imageUploadStatus == .failure {
                    isImagePickerDisplay.toggle()
                } else {
                    showImage.toggle()
                    imageUrlData = imageUrl
                }
            } label: {
                ZStack {
                    if imageUrl == "" {
                        Rectangle()
                            .fill(Color.Grey.PALE)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7.5)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundColor(Color.black.opacity(0.25))
                            )
                            .frame(height: 93.5)
                        
                        VStack {
                            Spacer()
                            
                            Image(IC.ACTIONS.CAMERA_PICK)
                            
                            Text("Add Image")
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.regular(12))
                            
                            Spacer()
                        }
                    } else {
                        WebUrlImage(url: imageUrl.url)
                            .scaledToFill()
                            .frame(height: 93.5, alignment: .center)
                            .cornerRadius(7.5)
                            .clipped()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .actionSheet(isPresented: $isImagePickerDisplay) {
            ActionSheet(title: Text("Choose Image".localizedString()), message: Text("Select a method".localizedString()), buttons: [
                .default(Text("Gallery".localizedString())) {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                    ImagePickerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
                        .localize()
                    }
                },
                .default(Text("Camera".localizedString())) {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ImagePickerView(selectedImage: $selectedImage, sourceType: .camera)
                            .localize()
                    }
                },
                .cancel()
            ])
        }
        .onChange(of: selectedImage, perform: { value in
            viewModel.upload(image: value) { isLoading in
                imageUploadStatus = .inProgress
            } completed: { url in
                imageUrl = url
                imageUrlGenerated(url)
                imageUploadStatus = .completed(url: url)
            } failure: {
                imageUploadStatus = .failure
            }
        })
    }
}

