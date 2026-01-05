//
//  CreateIncidentImageView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//


import SwiftUI
import PhotosUI
import SwiftUIX
import SwiftfulLoadingIndicators

struct CreateIncidentImageView: View {
    var imageUrlGenerated: (_ url: String) -> ()
    var descriptionChanged: (_ description: String) -> ()
    var minusButtonTapped: () -> ()
    var isViewOnly: Bool = false

    @StateObject var viewModel: CreateIncidentImageViewModel
    
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
    @State private var showAnnotator = false
    @State private var showCropTool = false
    @State private var isCropped: Bool = false
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
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
                        .disabled(isViewOnly)
                        .padding(.top, 23.5)
                        
                        imageView
                            .padding(.top, 13.5)
                        
//                        if imageUploadStatus == .inProgress {
//                            HStack {
//                                Spacer()
//
//                                Text("UPLOAD")
//                                    .foregroundColor(Color.white)
//                                    .font(.regular(12))
//                                    .frame(width: 80, height: 35)
//                                    .background(Color.Blue.THEME)
//                                    .cornerRadius(17.5)
//                            }
//                        }
                        
                        ThemeTextEditorView(text: $description,
                                            title: "description".localizedString(),
                                            disabled: false,
                                            keyboardType: .default,
                                            isMandatoryField: false,
                                            limit: Constants.Number.Limit.Observation.IMAGE_DESCRIPTION,
                                            placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: true
                        )
                        .disabled(isViewOnly)
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
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
            .onAppear {
                description = viewModel.item.description ?? ""
                imageUrl = viewModel.item.image ?? ""
                imageUploadStatus = imageUrl.isEmpty ? .pending : .completed(url: imageUrl)
            }
        }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(
                    selectedImage: $selectedImage,
                    sourceType: pickerSource
                )
            }
            .fullScreenCover(isPresented: $showCropTool) {
                TOCropView(image: selectedImage!, onCropped: { img in
                    isCropped = true
                    selectedImage = img
                    showAnnotator = true
                }, onCancel: {
                    showCropTool = false
                })
            .ignoresSafeArea()
        }
            .fullScreenCover(isPresented: $showAnnotator) {
                ModernDrawsanaWrapper(
                    image: selectedImage!,
                    onDone: { finalImg in
                        selectedImage = finalImg   // <-- IMPORTANT
                        uploadAnnotatedImage(finalImg)
                        showAnnotator = false
                    },
                    onCancel: {
                        isCropped = false
                        showAnnotator = false
                    }
                )
                .ignoresSafeArea()
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
                    if let img = selectedImage, imageUploadStatus == .completed(url: imageUrl) {
                        // SHOW LOCAL CROPPED / ANNOTATED IMAGE
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 93.5)
                            .cornerRadius(7.5)
                            .clipped()

                    } else if !imageUrl.isEmpty {
                        // ONLY SHOW URL IMAGE WHEN NO LOCAL IMAGE EXISTS
                        WebUrlImage(url: imageUrl.url)
                            .scaledToFill()
                            .frame(height: 93.5)
                            .cornerRadius(7.5)
                            .clipped()

                    } else {
                        // SHOW ADD IMAGE PLACEHOLDER
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
                            Text("add_image".localizedString())
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.regular(12))
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .actionSheet(isPresented: $isImagePickerDisplay) {
            ActionSheet(title: Text("choose_image".localizedString()), message: Text("select_a_method".localizedString()), buttons: [
                .default(Text("gallery".localizedString())) {
                    pickerSource = .photoLibrary
                        showImagePicker = true
                },
                .default(Text("camera".localizedString())) {
                    pickerSource = .camera
                        showImagePicker = true
                },
                .cancel()
            ])
        }
        .onChange(of: selectedImage) { newImage in
            if !isCropped {
                guard let img = newImage else { return }
                selectedImage = img
                showCropTool = true
            }
        }
    }
    
    func uploadAnnotatedImage(_ annotated: UIImage) {
        imageUploadStatus = .inProgress

        // Run compression OFF the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            let compressedImage = annotated.compressToMaximum()

            DispatchQueue.main.async {
                // Upload AFTER switching back to main thread
                viewModel.upload(image: compressedImage) { _ in
                } completed: { url in
                    imageUrl = url
                    imageUrlGenerated(url)
                    imageUploadStatus = .completed(url: url)
                } failure: {
                    isCropped = false
                    imageUploadStatus = .failure
                }
            }
        }
    }
}
