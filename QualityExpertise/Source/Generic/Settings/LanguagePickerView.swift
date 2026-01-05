import SwiftUI

struct LanguagePickerView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedLanguage = LocalizationService.shared.language
    @ObservedObject var viewModel: SettingsViewModel
    let onLanguageSelected: (Language) -> Void

    private let themeColor = Color(hex: "#00517E")

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    // MARK: - Background
                    LinearGradient(
                        colors: [Color.white, Color(hex: "#F4FAFD")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        Image("ic.language.icon")
                            .resizable()
                            .frame(width: 158, height :158)
                            .padding(.horizontal, 50)
                            .padding(.top, 60)
                        
                        // MARK: - Description
                        Text("choose_language_description".localizedString())
                            .leftAlign()
                            .font(.poppins(12))
                            .foregroundColor(Color.Grey.SLATE)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 28 + 5)
                            .padding(.top, 18)
                        
                        // MARK: - Language List
                        VStack(spacing: 14) {
                            ScrollView(.vertical, showsIndicators: false) {
                                ForEach(Language.allCases) { language in
                                    languageRow(for: language)
                                        .padding(.horizontal, 5)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 5)
                        
                        Spacer()
                        
                        // MARK: - Footer
                        VStack(spacing: 12) {
                            Text("you_can_change_language_later".localizedString())
                                .font(.lightItalic(9))
                                .foregroundColor(Color(hex: "#6B7280"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            ButtonWithLoader(
                                action: submitAction,
                                title: "submit".localizedString(),
                                width: geo.size.width - 56,
                                height: 48,
                                isLoading: $viewModel.isLoading
                            )
                            .padding(.bottom, 20)
                        }
                    }
                }
                .navigationBarTitle("select_language".localizedString(), displayMode: .inline)
                .toolbar {
                    BackButtonToolBarItem(action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
    }

}

// MARK: - Subviews
private extension LanguagePickerView {
    func languageRow(for language: Language) -> some View {
        let isSelected = selectedLanguage == language

        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeColor.opacity(selectedLanguage == language ? 0.2 : 0.1))
                    .frame(width: 40, height: 40)
                Text(language.shortCode)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeColor)
            }

            Text(language.description)
                .font(.regular(16))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: selectedLanguage == language ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selectedLanguage == language ? themeColor : .gray.opacity(0.4))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? themeColor.opacity(0.08) : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? themeColor : Color.gray.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { selectedLanguage = language }
    }

    func submitAction() {
        presentationMode.wrappedValue.dismiss()
        onLanguageSelected(selectedLanguage)
    }
}


