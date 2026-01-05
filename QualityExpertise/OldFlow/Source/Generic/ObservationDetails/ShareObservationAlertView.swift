//
//  ShareObservationAlertView.swift
// ALNASR
//
//  Created by Developer on 06/07/22.
//

import SwiftUI

struct ShareObservationAlertView: View {
    
    @Binding var viewerShown: Bool
    @State private var isPDFSelected: Bool = false
    
    var completion: (Bool)->()
    
    @ViewBuilder
    var body: some View {
        VStack {
            if viewerShown {
                ZStack {
                    Color(red: 0, green: 0, blue: 0, opacity: 0.85)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        
                        HStack(spacing: 8.5) {
                            
                            Image(IC.SHARE.WHATSAPP)
                                .padding(.leading, 2.5)
                                .frame(width: 28, height: 28)
                            
                            Text("Share Document")
                                .font(.semiBold(14))
                                .foregroundColor(Color.Indigo.DARK)
                            
                            Spacer()
                            
                            Button(action: {
                                viewerShown.toggle()
                            }) {
                                Image(IC.ACTIONS.CLOSE)
                                    .frame(width: 15, height: 15)
                            }
                        }
                        .padding(.leading, 22.5)
                        .padding(.trailing, 28)
                        .padding(.top, 25.5)
                        .padding(.bottom, 13)
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            isPDFSelected = false
                            
                        }) {
                            HStack(spacing: 12.5) {
                                
                                Image(IC.SHARE.TEXT_DOCUMENT)
                                    .padding(.leading, 3.5)
                                    .frame(width: 22, height: 26.5)
                                
                                Text("Text Format")
                                    .font(.medium(12))
                                    .foregroundColor(Color.Indigo.DARK)

                                Spacer()
                                
                                Image(!isPDFSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                                    .renderingMode(.original)
                                    .frame(width: 18.0, height: 18.0)
                                    .padding(.trailing, 5)
                            }
                        }
                        .padding(.horizontal, 23.5)
                        .padding(.top, 15)
                        
                        Button(action: {
                            isPDFSelected = true
                            
                        }) {
                            HStack(spacing: 12.5) {
                                
                                Image(IC.SHARE.PDF_DOCUMENT)
                                    .padding(.leading, 3.5)
                                    .frame(width: 22, height: 26.5)
                                
                                Text("PDF Format")
                                    .font(.medium(12))
                                    .foregroundColor(Color.Indigo.DARK)

                                Spacer()
                                
                                Image(isPDFSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                                    .renderingMode(.original)
                                    .frame(width: 18.0, height: 18.0)
                                    .padding(.trailing, 5)
                            }
                        }
                        .padding(.horizontal, 23.5)
                        .padding(.top, 21.5)
                        
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                viewerShown.toggle()
                                completion(isPDFSelected)
                            }) {
                                Text("OK")
                                    .font(.medium(14))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(width: 101, height: 37)
                            .background(Color.Blue.THEME)
                            .cornerRadius(18.5)
                            
                            Spacer()
                        }
                        .padding(.top, 32.5)
                        .padding(.bottom, 25.5)
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

