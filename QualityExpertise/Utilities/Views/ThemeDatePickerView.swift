//
//  ThemeDatePickerView.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//
import SwiftUI

struct ThemeDatePickerView: View {
    @Binding var date: Date?
    var title: String
    var disabled: Bool = false
    var showTitle: Bool = true
    var isMandatoryField: Bool = true
    var isDividerShown: Bool? = true
    var foregroundColor: Color = Color.Indigo.DARK
    var placeholderColor: Color = Color.Grey.GUNMENTAL.opacity(0.25)
    var isOptionalTextView: Bool = false
    var displayFormat: String = "MMM dd, yyyy"
    var placeholder: String
    var isTimePicker: Bool = false
    
    @Binding var showDatePicker: Bool
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = isTimePicker ? "hh:mm a" : displayFormat
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showTitle {
                HStack(spacing: 2) {
                    Text(title.uppercased())
                        .foregroundColor(Color.Blue.GREY)
                        .font(.regular(12))
                    
                    if isOptionalTextView {
                        Text("(OPTIONAL)")
                            .foregroundColor(Color.Blue.GREY)
                            .font(.regular(12))
                    }
                    
                    if isMandatoryField {
                        Text("*")
                            .foregroundColor(Color.Red.CORAL)
                            .font(.regular(12))
                    }
                    
                    Spacer()
                }
            }
            
            HStack {
                if let date = date {
                    Text(dateFormatter.string(from: date))
                        .font(.regular(14))
                        .foregroundColor(foregroundColor)
                } else {
                    Text(placeholder)
                        .font(.regular(12))
                        .foregroundColor(placeholderColor)
                }
                
                Spacer()
                
                if isTimePicker {
                    Image(IC.DASHBOARD.TAB.PENDING_ACTIONS_SELECTED)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color.Green.DARK_GREEN)
                } else {
                    Image(isTimePicker ? IC.DASHBOARD.TAB.PENDING_ACTIONS_SELECTED : IC.PLACEHOLDER.CALENDER)
                        .foregroundColor(Color.Green.DARK_GREEN)
                }
            }
            .frame(height: 42)
            .contentShape(Rectangle())
            .onTapGesture {
                if !disabled {
                    withAnimation {
                        if !isTimePicker {
                            if self.date == nil {
                                self.date = Date()
                            }
                        }
                        showDatePicker.toggle()
                    }
                }
            }
            
            if isDividerShown ?? true {
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
        }
    }
}

struct ThemeDatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var date: Date? = nil
        return VStack {
            ThemeDatePickerView(
                date: $date,
                title: "Birth Date",
                placeholder: "Select birth date", showDatePicker: .constant(false)
            )
            .padding()
            
            Spacer()
        }
    }
}
