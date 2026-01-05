//
//  PrivacyPolicyContentView.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import SwiftUI
import WebKit
import SwiftfulLoadingIndicators

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.white
        webView.scrollView.backgroundColor = UIColor.white
        webView.scrollView.showsVerticalScrollIndicator = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <head>
            <style>
                @font-face {
                    font-family: 'Poppins';
                    src: url('Poppins-Regular.ttf')  format('truetype')
                }
                img {
                    width: 100%;
                }
                body {
                    font-family: 'Poppins';
                    font-size: 30px;
                    color:Color.Blue.DARK_BLUE_GREY;
                }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """

        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
        uiView.loadHTMLString(html, baseURL: baseURL)
    }
}

struct HTMLText: UIViewRepresentable {
    
    let html: String
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()
        label.textColor = Color.Blue.DARK_BLUE_GREY.toUIColor()
        label.font = UIFont.regular(size: 19)
        DispatchQueue.main.async {
            let data = Data(self.html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                label.attributedText = attributedString
            }
        }
        
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {}
}

struct PrivacyPolicyContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = PrivacyPolicyViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                if let error = viewModel.error {
                    error.viewRetry {
                        viewModel.fetchDetails()
                    }
                } else {
                    VStack(spacing: 30) {
                        Image(IC.LOGO.ABOUT_US)
                        
                        HTMLStringView(htmlContent: viewModel.content)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .disabled(viewModel.isLoading)
                }
                
                VStack {
                    if viewModel.isLoading {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .navigationBarTitle("Privacy Policy", displayMode: .inline)
            .toolbar(content: {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            })
            .onAppear(perform: viewModel.fetchDetails)
            .listenToAppNotificationClicks()
        }
    }
}

struct PrivacyPolicyContentView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyContentView()
    }
}
