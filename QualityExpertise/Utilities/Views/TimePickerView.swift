//
//  TimePickerView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

import SwiftUI

struct TimePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTime: Date?
    @Binding var showTimePicker: Bool
    var selectedDate: Date?
    
    var body: some View {
        if showTimePicker {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showTimePicker.toggle()
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Image(colorScheme == .dark ? IC.ACTIONS.CLOSE_WHITE : IC.ACTIONS.CLOSE)
                            .font(.regular(12))
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                            .onTapGesture {
                                withAnimation {
                                    showTimePicker.toggle()
                                }
                            }
                            .leftAlign()
                            .padding()
                        
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { self.selectedTime ?? defaultTime },
                                set: { self.selectedTime = $0 }
                            ),
                            in: allowedRange,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onAppear {
                            // Normalize selectedTime to respect rules
                            if let selectedTime = selectedTime {
                                if !allowedRange.contains(selectedTime) {
                                    self.selectedTime = defaultTime
                                }
                            } else {
                                self.selectedTime = defaultTime
                            }
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .transition(.asymmetric(insertion: .move(edge: .bottom),
                                            removal: .move(edge: .bottom)))
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom),
                                        removal: .move(edge: .bottom)))
            }
        }
    }
    
    /// Default time logic
    private var defaultTime: Date {
        let calendar = Calendar.current
        let baseDate = selectedDate ?? Date()
        
        if calendar.isDateInToday(baseDate) {
            return Date() // Now
        } else if baseDate < calendar.startOfDay(for: Date()) {
            // Past day → 11:59 PM
            let startOfDay = calendar.startOfDay(for: baseDate)
            return calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                .addingTimeInterval(-60) // 23:59
        } else {
            // Future date (if somehow passed) → default to start of day
            return calendar.startOfDay(for: baseDate)
        }
    }
    
    /// Allowed range for the picker
    private var allowedRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let baseDate = selectedDate ?? Date()
        
        if calendar.isDateInToday(baseDate) {
            let startOfDay = calendar.startOfDay(for: baseDate)
            return startOfDay...Date() // today → up to now
        } else if baseDate < calendar.startOfDay(for: Date()) {
            let startOfDay = calendar.startOfDay(for: baseDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                .addingTimeInterval(-1) // end of day
            return startOfDay...endOfDay
        } else {
            // If future date slips in, allow only start of day
            let startOfDay = calendar.startOfDay(for: baseDate)
            return startOfDay...startOfDay
        }
    }
}


