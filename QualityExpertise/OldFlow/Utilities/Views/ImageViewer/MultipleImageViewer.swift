//
//  MultipleImageViewer.swift
// ALNASR
//
//  Created by developer on 01/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

extension View {
    func imageViewerOverlay(viewerShown: Binding<Bool>, images: [String], selectedImageIndex: Int = 0) -> some View {
        overlay(MultipleImageViewer(viewerShown: viewerShown, images: images, selectedImageTag: selectedImageIndex))
    }
}

struct MultipleImageViewer: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var scale: CGFloat = 1.0
    
    @Binding var viewerShown: Bool
    var images: [String]
    @State var selectedImageTag = 0

    @ViewBuilder
    var body: some View {
        VStack {
            if viewerShown, images.count > 0 {
                VStack {
                    ZStack {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    viewerShown.toggle()
                                }, label: {
                                    Image(IC.ACTIONS.CLOSE_WHITE)
                                        .shadow(radius: 3)
                                        .padding()
                                })
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .zIndex(2)
                        
                        TabView(selection: $selectedImageTag) {
                            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                URLImage(url: image)
                                    .scaleEffect(scale)
                                    .frame(width: screenWidth)
                                    .gesture(MagnificationGesture()
                                                .onChanged { value in
                                        if value.magnitude >= 0.8 {
                                            self.scale = value.magnitude
                                        }
                                                })
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: images.count <= 1 ? .never : .always))
                        .onChange(of: selectedImageTag) { _ in
                            self.scale = 1.0
                        }
                        .zIndex(1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0, green: 0, blue: 0, opacity: 0.85).edgesIgnoringSafeArea(.all))
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                .onAppear() {
                    self.scale = 1.0
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
