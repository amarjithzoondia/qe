//
//  OTPInputView.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import SwiftUI

struct OTPInputView: View {
    var width: CGFloat
    var height: CGFloat
    var maxDigits: Int = 4
    @Binding var pin: String
    var isDeletingAccount: Bool
    var handler: (String, (Bool) -> Void) -> Void
    
    @State var isDisabled = false
    
    var body: some View {
        ZStack {
            pinDots
            backgroundField
        }
        .frame(width: width, height: height)
    }
    
    private var pinDots: some View {
        HStack(spacing: 6) {
            if isDeletingAccount {
                ForEach(0..<maxDigits) { index in
                    VStack(spacing: 0) {
                        Text(self.getNumberString(at: index))
                            .foregroundColor(Color.Grey.GUNMENTAL)
                            .font(.regular(16))

                        VStack {}
                            .frame(width: 15, height: 1)
                            .background(Color.Grey.GUNMENTAL)
                    }
                }
            } else {
                ForEach(0..<maxDigits) { index in
                    ZStack {
                        Color.Grey.PALE_THREE

                        Text(self.getNumberString(at: index))
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(18))
                    }
                    .cornerRadius(10)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)  // 🔥 Only boxes stay LTR
    }

    
    private var backgroundField: some View {
        let boundPin = Binding<String>(get: { self.pin }, set: { newValue in
            self.pin = newValue
            self.submitPin()
        })
        
        return TextField("", text: boundPin, onCommit: submitPin)
            .accentColor(.clear)
            .foregroundColor(.clear)
            .keyboardType(.numberPad)
    }
    
    private func getNumberString(at index: Int) -> String {
        if index >= self.pin.count {
            return ""
        }
        
        func numberString(from index: Int) -> String {
            guard index < 10 else { return "0" }
            return String(index)
        }
        
        func digits(from string: String) -> [Int] {
            var result = [Int]()
            for char in string {
                if let number = Int(String(char)) {
                    result.append(number)
                }
            }
            return result
        }
        
        return numberString(from: digits(from: self.pin)[index])
    }
    
    private func submitPin() {
        
        guard !pin.isEmpty else {
            return
        }
        
        if pin.count == maxDigits {
            isDisabled = true
            handler(pin) { isSuccess in
                if isSuccess {
                    print("pin matched, go to next page, no action to perfrom here")
                } else {
                    pin = ""
                    isDisabled = false
                    print("this has to called after showing toast why is the failure")
                }
            }
            return
        }
        
        
        if pin.count > maxDigits {
            pin = String(pin.prefix(maxDigits))
            submitPin()
        }
    }
}

