//
//  LogInInputViews.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

struct PasswordLoginInputView: View {
    @Binding var password: String
    @State var isPasswordShow: Bool?
    
    var body: some View {
        return HStack {
            Image(IC.PLACEHOLDER.PASSWORD)
                .padding(.leading, 18.5)
            
            if isPasswordShow ?? false {
                TextField("", text: $password)
                    .modifier(TextFieldInputViewStyle(placeholder: "Password".localizedString(), text: $password))
                    .padding(.leading, 10.5)
                    .font(.regular(12))
            } else {
                SecureField("", text: $password)
                    .modifier(TextFieldInputViewStyle(placeholder: "Password".localizedString(), text: $password))
                    .padding(.leading, 10.5)
                    .font(.regular(12))
                
            }
            
            Spacer()
            
            Button {
                isPasswordShow = !(isPasswordShow ?? false)
            } label: {
                if isPasswordShow ?? false {
                    Image(IC.PLACEHOLDER.EYE_OPEN)
                        .foregroundColor(Color.Blue.THEME)
                } else {
                    Image(IC.PLACEHOLDER.EYE_CLOSE)
                        .foregroundColor(Color.Blue.THEME)
                }
            }
            .padding(.trailing, 15)
        }
    }
}

struct PasswordView: View {
   
    @Binding var password: String
    var isConfirmPassword: Bool = false
    
    var body: some View {
        VStack {
            LeftAlignedHStack(
                Text(isConfirmPassword ? "CONFIRM PASSWORD" : "PASSWORD")
                    .font(.regular(12))
                    .foregroundColor(Color.Blue.GREY)
            )
            
            LeftAlignedHStack(
                SecureField("", text: $password)
                    .font(.medium(15))
                    .foregroundColor(Color.Indigo.DARK)
                    .autocapitalization(.none)
            )
            
            if !isConfirmPassword {
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
        }
    }
}



struct EmailInputView: View {
    @Binding var email: String

    var body: some View {
        HStack {
            Image(IC.PLACEHOLDER.EMAIL)
                .padding(.leading, 18.5)
            
            TextField("", text: $email)
                .lineLimit(1)
                .modifier(TextFieldInputViewStyle(placeholder: "Email Address".localizedString(), text: $email))
                .padding(.leading, 10.5)
                .keyboardType(.asciiCapable)
                .autocapitalization(.none)
        }
    }
}

struct LoginInputViewModifier: ViewModifier {
    
    var frame: CGRect
    var backgroundColor = Color.Grey.PALE

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: 41)
            .background(backgroundColor)
            .cornerRadius(25)
    }
}
