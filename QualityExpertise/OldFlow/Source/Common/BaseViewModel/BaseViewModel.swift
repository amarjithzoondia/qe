//
//  BaseViewModel.swift
// ALNASR
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
}

