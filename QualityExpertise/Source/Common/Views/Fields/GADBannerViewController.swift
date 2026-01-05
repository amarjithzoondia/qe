//
//  GADBannerViewController.swift
// QualityExpertise
//
//  Created by developer on 15/02/22.
//

import SwiftUI
import UIKit
import GoogleMobileAds

//final class GADBannerViewController: UIViewControllerRepresentable  {
struct GADBannerViewController: UIViewControllerRepresentable  {

    func makeUIViewController(context: Context) -> UIViewController {
        let view = BannerView(adSize: AdSizeBanner)
        let viewController = UIViewController()
        view.adUnitID = Configurations.AD.AD_UNIT_ID
        view.rootViewController = viewController
        view.delegate = viewController as? BannerViewDelegate
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: AdSizeBanner.size)
        view.load(Request())
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

