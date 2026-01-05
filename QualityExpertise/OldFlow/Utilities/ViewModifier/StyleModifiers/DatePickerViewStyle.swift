//
//  DatePickerViewStyle.swift
// ALNASR
//
//  Created by developer on 01/03/22.
//

import SwiftUI

struct DatePickerViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
    }
}

