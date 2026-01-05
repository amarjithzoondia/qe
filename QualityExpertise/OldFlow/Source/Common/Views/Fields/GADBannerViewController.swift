//
//  GADBannerViewController.swift
// ALNASR
//
//  Created by developer on 15/02/22.
//

import SwiftUI
import UIKit
import GoogleMobileAds

//final class GADBannerViewController: UIViewControllerRepresentable  {
struct GADBannerViewController: UIViewControllerRepresentable  {

    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: GADAdSizeBanner)
        let viewController = UIViewController()
        view.adUnitID = Configurations.AD.AD_UNIT_ID
        view.rootViewController = viewController
        view.delegate = viewController as? GADBannerViewDelegate
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: GADAdSizeBanner.size)
        view.load(GADRequest())
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

