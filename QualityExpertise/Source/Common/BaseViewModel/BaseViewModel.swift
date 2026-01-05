//
//  BaseViewModel.swift
// QualityExpertise
//
//  Created by developer on 28/01/22.
//

import Foundation
import SwiftUI

class BaseViewModel: NSObject {
    @Published var error: SystemError?
    @Published var isLoading = false
    @Published var isActionsLoading = false
    @Published var showToast = false
    @Published var showAlert = false
    @Published var noDataFound = false
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading: Bool = false
    @Published var pdfLoading: Bool = false
    var toast: AlertToast = Toast.alert(subTitle: "") {
        didSet {
            showToast = true
        }
    }
    
    var alert: Alert = Alert.alert() {
        didSet {
            showAlert = true
        }
    }
    
    var loader: AlertToast = AlertToast(type: .loading, style: AlertToast.AlertStyle.style(backgroundColor: Color.Indigo.DARK))
    
    func showLoader(loading: Bool) {
        if loading {
            showToast = false
        }
        isLoading = loading
    }
    
    func showActionsLoader(loading: Bool) {
        if loading {
            showToast = false
        }
        isActionsLoading = loading
    }
    
    func onAppear() {
        
    }
    
    func onRefresh() {
        fetchDetails()
    }
    
    func onRetry() {
        self.error = nil
        self.noDataFound = false
    }
    
    func fetchDetails() {
        self.error = nil
        self.noDataFound = false
    }
    
    func refreshData(userInfo: [AnyHashable : Any]?) {
        
    }
    
    func savePdfWithProgress(urlString: String, fileName: String) {
        guard let url = URL(string: urlString) else { return }

        isDownloading = true
        downloadProgress = 0.0

        let downloader = PDFDownloader()

        // REAL PROGRESS → smooth UI progress
        downloader.onProgress = { progress in
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.2)) {
                    self.downloadProgress = progress
                }
            }
        }

        downloader.onComplete = { tempURL in
            do {
                let docPath = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first!
                let finalURL = docPath.appendingPathComponent(fileName)

                if FileManager.default.fileExists(atPath: finalURL.path) {
                    try FileManager.default.removeItem(at: finalURL)
                }

                try FileManager.default.moveItem(at: tempURL, to: finalURL)

                // Animate to 100% smoothly
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 0.2)) {
                        self.downloadProgress = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.toast = "pdf_saved_success".localizedString().successToast
                        self.isDownloading = false

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.downloadProgress = 0.0
                        }
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.toast = Toast.alert(subTitle: "pdf_save_failed".localizedString())
                    self.isDownloading = false
                }
            }
        }

        downloader.onError = { error in
            DispatchQueue.main.async {
                print(error)
                self.toast = Toast.alert(subTitle: "pdf_save_failed".localizedString())
                self.isDownloading = false
            }
        }

        downloader.downloadPDF(from: url)
    }

}

