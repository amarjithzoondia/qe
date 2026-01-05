//
//  DatePickerView.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

import SwiftUI

struct DatePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedDate: Date?
    @Binding var showDatePicker: Bool
    
    
    var body: some View {
        if showDatePicker {
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Image(colorScheme == .dark ? IC.ACTIONS.CLOSE_WHITE : IC.ACTIONS.CLOSE)
                            .font(.regular(12))
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                            .onTapGesture {
                                withAnimation {
                                    showDatePicker.toggle()
                                }
                            }
                            .leftAlign()
                            .padding()
                        
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { self.selectedDate ?? Date() },
                                set: { self.selectedDate = $0 }
                            ),
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()

                    }
                    .background(Color(UIColor.systemBackground))
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                .onTapGesture {
                    withAnimation {
                        showDatePicker.toggle()
                    }
                }
            }
        }
    }
}


#Preview {
    DatePickerView(selectedDate: .constant(Date()), showDatePicker: .constant(false))
}
