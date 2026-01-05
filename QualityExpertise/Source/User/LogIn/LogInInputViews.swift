//
//  LogInInputViews.swift
//  QualityExpertise
//

import SwiftUI
import UIKit

// ---------------------------------------------------------
// MARK: - PASSWORD LOGIN INPUT VIEW
// ---------------------------------------------------------

struct PasswordLoginInputView: View {
    @Binding var password: String
    @State var isPasswordShow: Bool?

    var body: some View {
        HStack {
            Image(IC.PLACEHOLDER.PASSWORD)
                .padding(.leading, 18.5)

            // 👉 When visible: UIKit normal text field
            if isPasswordShow ?? false {
                UIKitPasswordField(
                    text: $password,
                    placeholder: "password".localizedString(),
                    isSecure: false,                   // normal mode
                    font: .regular(size: 12),
                    textColor: UIColor(Color.Indigo.DARK),
                    placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                    isRTL: LocalizationService.shared.language.isRTLLanguage
                )
                .padding(.leading, 10.5)

            } else {
                // 👉 UIKit secure field
                UIKitPasswordField(
                    text: $password,
                    placeholder: "password".localizedString(),
                    isSecure: true,
                    font: .regular(size: 12),
                    textColor: UIColor(Color.Indigo.DARK),
                    placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                    isRTL: LocalizationService.shared.language.isRTLLanguage
                )
                .padding(.leading, 10.5)
            }

            Spacer()

            Button {
                isPasswordShow = !(isPasswordShow ?? false)
            } label: {
                Image(isPasswordShow ?? false ? IC.PLACEHOLDER.EYE_OPEN : IC.PLACEHOLDER.EYE_CLOSE)
                    .foregroundColor(Color.Blue.THEME)
            }
            .padding(.trailing, 15)
        }
    }
}

// ---------------------------------------------------------
// MARK: - PASSWORD (CONFIRM) VIEW
// ---------------------------------------------------------

struct PasswordView: View {

    @Binding var password: String
    var isConfirmPassword: Bool = false

    var body: some View {
        VStack {
            LeftAlignedHStack(
                Text(isConfirmPassword ? "confirm_password".localizedString() : "password".localizedString())
                    .font(.regular(12))
                    .foregroundColor(Color.Blue.GREY)
            )

            LeftAlignedHStack(
                UIKitPasswordField(
                    text: $password,
                    placeholder: "",
                    isSecure: true,
                    font: .regular(size: 12),
                    textColor: UIColor(Color.Indigo.DARK),
                    placeholderColor: .clear,
                    isRTL: LocalizationService.shared.language.isRTLLanguage
                )
            )

            if !isConfirmPassword {
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
        }
    }
}

// ---------------------------------------------------------
// MARK: - EMAIL INPUT VIEW
// ---------------------------------------------------------

struct EmailInputView: View {
    @Binding var email: String

    var body: some View {
        HStack {
            Image(IC.PLACEHOLDER.EMAIL)
                .padding(.leading, 18.5)

            UIKitStyledTextField(
                text: $email,
                placeholder: "email_address".localizedString(),
                font: .regular(size: 12),
                textColor: UIColor(Color.Indigo.DARK),
                placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                height: 41,
                isRTL: LocalizationService.shared.language.isRTLLanguage,
                keyboardType: .asciiCapable
            )
            .padding(.leading, 10.5)
        }
    }
}

// ---------------------------------------------------------
// MARK: - LOGIN INPUT VIEW MODIFIER
// ---------------------------------------------------------

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

// ---------------------------------------------------------
// MARK: - UIKit NORMAL TEXTFIELD WRAPPER
// ---------------------------------------------------------

struct UIKitStyledTextField: UIViewRepresentable {
    @Binding var text: String

    var placeholder: String
    var font: UIFont
    var textColor: UIColor
    var placeholderColor: UIColor
    var height: CGFloat
    var isRTL: Bool
    var keyboardType: UIKeyboardType

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> StyledTextFieldUIKit {
        let view = StyledTextFieldUIKit()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: StyledTextFieldUIKit, context: Context) {
        uiView.configure(
            text: text,
            placeholder: placeholder,
            font: font,
            textColor: textColor,
            placeholderColor: placeholderColor,
            height: height,
            isRTL: isRTL,
            keyboardType: keyboardType,
        )
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UIKitStyledTextField
        
        init(_ parent: UIKitStyledTextField) { self.parent = parent }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

// ---------------------------------------------------------
// MARK: - UIKit SECURE / NORMAL PASSWORD FIELD WRAPPER
// ---------------------------------------------------------

struct UIKitPasswordField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool
    var font: UIFont
    var textColor: UIColor
    var placeholderColor: UIColor
    var isRTL: Bool
    var isPlaceholderShown: Bool = true
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> PasswordTextFieldUIKit {
        let field = PasswordTextFieldUIKit()
        field.delegate = context.coordinator
        return field
    }

    func updateUIView(_ uiView: PasswordTextFieldUIKit, context: Context) {
        uiView.configure(
            text: text,
            placeholder: placeholder,
            isSecure: isSecure,
            font: font,
            textColor: textColor,
            placeholderColor: placeholderColor,
            isRTL: isRTL,
            isPlaceHolderShown: isPlaceholderShown
        )
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UIKitPasswordField

        init(_ parent: UIKitPasswordField) { self.parent = parent }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

// ---------------------------------------------------------
// MARK: - UIKit NORMAL TEXTFIELD
// ---------------------------------------------------------

class StyledTextFieldUIKit: UIView, UITextFieldDelegate {

    let textField = UITextField()
    weak var delegate: UITextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame); setupUI()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI() }

    private func setupUI() {
        addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 41)
        ])
    }

    func configure(
        text: String,
        placeholder: String,
        font: UIFont,
        textColor: UIColor,
        placeholderColor: UIColor,
        height: CGFloat,
        isRTL: Bool,
        keyboardType: UIKeyboardType
    ) {
        textField.text = text
        textField.autocapitalizationType = .none
        textField.font = font
        textField.textColor = textColor
        textField.delegate = delegate
        textField.keyboardType = keyboardType
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: placeholderColor, .font: font]
        )

        textField.textAlignment = isRTL ? .right : .left
        textField.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        frame.size.height = height
    }
}

// ---------------------------------------------------------
// MARK: - UIKit SECURE TEXTFIELD
// ---------------------------------------------------------

class PasswordTextFieldUIKit: UIView, UITextFieldDelegate {

    let textField = UITextField()
    weak var delegate: UITextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame); setupUI()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI() }

    private func setupUI() {
        addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 41)
        ])
    }

    func configure(
        text: String,
        placeholder: String,
        isSecure: Bool,
        font: UIFont,
        textColor: UIColor,
        placeholderColor: UIColor,
        isRTL: Bool,
        isPlaceHolderShown: Bool
    ) {
        textField.text = text
        textField.font = font
        textField.textColor = textColor
        textField.isSecureTextEntry = isSecure
        textField.delegate = delegate
        if isPlaceHolderShown {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: placeholderColor, .font: font]
            )
        }
        textField.textAlignment = isRTL ? .right : .left
        textField.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    }
}
