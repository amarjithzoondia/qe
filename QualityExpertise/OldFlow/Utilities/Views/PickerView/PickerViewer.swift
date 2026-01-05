//
//  PickerViewer.swift
// ALNASR
//
//  Created by developer on 27/01/22.
//

import SwiftUI

extension View {
    func pickerViewerOverlay<Content: View>(viewerShown: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) -> some View {
        overlay(PickerViewer(viewerShown: viewerShown, title: title, content: content))
    }
}

struct PickerViewer<Content: View>: View {
    internal init(viewerShown: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) {
        _viewerShown = viewerShown
        self.title = title
        self.content = content()
    }
    
    @Binding var viewerShown: Bool
    let title: String
    let content: Content
    
    @ViewBuilder
    var body: some View {
        VStack {
            if viewerShown {
                ZStack {
                    Color(red: 0, green: 0, blue: 0, opacity: 0.85)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            viewerShown.toggle()
                        }
                    
                    VStack {
                        HStack {
                            Text(title)
                                .font(.semiBold(18))
                                .foregroundColor(.Indigo.DARK)
                            
                            Spacer()
                            
                            Button(action: {
                                viewerShown.toggle()
                            }, label: {
                                Image(IC.ACTIONS.CLOSE)
                            })
                        }
                        .padding()

                        content
                            .colorScheme(.light)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 45)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
