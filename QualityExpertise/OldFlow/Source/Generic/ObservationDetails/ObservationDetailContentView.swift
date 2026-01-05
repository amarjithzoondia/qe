//
//  ObservationDetailContentView.swift
// ALNASR
//
//  Created by developer on 23/02/22.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX

struct ObservationDetailContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: ObservationDetailViewModel
    let closeObservationPublisher = NotificationCenter.default.publisher(for: .CLOSE_OBSERVATION)
    @State private var showAlertForDeleteObservation: Bool = false
    @State private var imageData: String?
    @State private var showObservationImage: Bool = false
    @State private var showObservationCloseImage: Bool = false
    @State private var showShareDocumentAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if let error = viewModel.error {
                        error.viewRetry {
                            viewModel.onRetry()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                LeftAlignedHStack(
                                    Text(viewModel.isGuestUser ? viewModel.guestObservationDetails.observationTitle : viewModel.observationDetails.observationTitle)
                                        .foregroundColor(Color.Indigo.DARK)
                                        .font(.semiBold(19))
                                )
                                
                                HStack {
                                    VStack {
                                        Text(viewModel.isGuestUser ? viewModel.guestObservationDetails.status.description : viewModel.observationDetails.status.description)
                                            .foregroundColor(Color.white)
                                            .font(.light(12))
                                            .padding(.horizontal, 10)
                                            .frame(height: 28)
                                    }
                                    .background(viewModel.isGuestUser ? viewModel.guestObservationDetails.status.backGroundColor : viewModel.observationDetails.status.backGroundColor)
                                    .cornerRadius(3.5)
                                    .padding(.top, 13.5)
                                    
                                    Spacer()
                                }
                                
                                if viewModel.isGuestUser {
                                    if viewModel.guestObservationDetails.description != "" {
                                        LeftAlignedHStack(
                                            Text(viewModel.guestObservationDetails.description ?? "NA")
                                                .foregroundColor(Color.Blue.BLUE_GREY)
                                                .font(.light(12))
                                        )
                                            .padding(.top, 13.5)
                                    } else {
                                        LeftAlignedHStack(
                                            Text("NA")
                                                .foregroundColor(Color.Blue.BLUE_GREY)
                                                .font(.light(12))
                                        )
                                            .padding(.top, 13.5)
                                    }
                                } else {
                                    if viewModel.observationDetails.description != "" {
                                        LeftAlignedHStack(
                                            Text(viewModel.observationDetails.description ?? "NA")
                                                .foregroundColor(Color.Blue.BLUE_GREY)
                                                .font(.light(12))
                                        )
                                            .padding(.top, 13.5)
                                    } else {
                                        LeftAlignedHStack(
                                            Text("NA")
                                                .foregroundColor(Color.Blue.BLUE_GREY)
                                                .font(.light(12))
                                        )
                                            .padding(.top, 13.5)
                                    }
                                }
                                
                                if viewModel.isGuestUser {
                                    if viewModel.guestObservationDetails.location != "" {
                                        HStack(spacing: 5) {
                                            Image(IC.PLACEHOLDER.LOCATION)
                                                .foregroundColor(Color.Blue.THEME)
                                            
                                            Text(viewModel.guestObservationDetails.location ?? "NA")
                                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                                .font(.medium(12))
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 13.5)
                                    }
                                } else {
                                    if viewModel.observationDetails.location != "" {
                                        HStack(spacing: 5) {
                                            Image(IC.PLACEHOLDER.LOCATION)
                                                .foregroundColor(Color.Blue.THEME)
                                            
                                            Text(viewModel.observationDetails.location ?? "NA")
                                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                                .font(.medium(12))
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 13.5)
                                    }
                                }
                                
                                
                                if !(UserManager.getCheckOutUser()?.isGuestUser ?? false) {
                                    if viewModel.observationDetails.group != nil {
                                        groupView
                                            .padding(.top, 15.5)
                                    }
                                }
                                
                                observationImageView
                                    .padding(.top, 31.5)
                                
                                reportedByView
                                    .padding(.top, 31.5)
                                
                                reponsiblePersonView
                                    .padding(.top, 31.5)
                                
                                if viewModel.isGuestUser {
                                    if viewModel.guestObservationDetails.status == .closedObservations {
                                        closeDetailsView
                                            .padding(.top, 31.5)
                                    }
                                } else {
                                    if viewModel.observationDetails.closeDetails != nil {
                                        closeDetailsView
                                            .padding(.top, 31.5)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 21)
                            .padding(.horizontal, 28.5)
                        }
                        
                        VStack {
                            
                            if viewModel.isGuestUser {
                                if viewModel.guestObservationDetails.status == .openObservations {
                                    CloseObservationButtonView
                                        .padding(.horizontal, 28.5)
                                        .padding(.top, 20)
                                }
                                
                                DeleteObservationButtonView
                                    .padding(.horizontal, 28.5)
                                    .padding(.top, 20)
                            } else {
                                if !(viewModel.observationDetails.groupSpecified ?? false) {
                                    if viewModel.observationDetails.status == .openObservations {
                                        CloseObservationButtonView
                                            .padding(.top, 20)
                                            .padding(.horizontal, 28.5)
                                    }
                                } else if viewModel.observationDetails.groupSpecified ?? false {
                                    if viewModel.observationDetails.isCancelable ?? false && viewModel.observationDetails.status == .openObservations {
                                        CloseObservationButtonView
                                            .padding(.top, 20)
                                            .padding(.horizontal, 28.5)
                                    }
                                }
                                
                                if viewModel.observationDetails.groupSpecified ?? false {
                                    if viewModel.observationDetails.group?.userRole == .superAdmin || viewModel.observationDetails.group?.userRole == .admin {
                                        DeleteObservationButtonView
                                            .padding(.horizontal, 28.5)
                                            .padding(.top, 20)
                                    }
                                } else {
                                    DeleteObservationButtonView
                                        .padding(.horizontal, 28.5)
                                        .padding(.top, 20)
                                }
                            }
                        }
                        .frame(width: screenWidth)
                        .padding(.bottom, 30)
                        .background(Color.white)
                    }
                    
                }
                
                if viewModel.isLoading {
                    Color.white.opacity(0.25)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 5){
                        Button {
                            generatePdf()
                        } label: {
                            Text("Generate PDF")
                                .foregroundColor(Color.white)
                                .font(.medium(12))
                                .frame(width: 125, height: 33.5)
                                .background(Color.Blue.THEME)
                                .cornerRadius(16.75)
                        }
                        
                        Button {
                            showShareDocumentAlert.toggle()
                        } label: {
                            Image(IC.ACTIONS.SHARE)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchObservationDetails()
            }
            .onReceive(closeObservationPublisher) { (output) in
                viewModel.fetchObservationDetails()
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
        .overlay(ShareObservationAlertView(viewerShown: $showShareDocumentAlert) { isPDFSelected in
            
            if !isPDFSelected {
                let message = viewModel.getShareMessage()
                let urlWhats = "whatsapp://send?text=\(message)"
                if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                    if let whatsappURL = URL(string: urlString) {
                        if UIApplication.shared.canOpenURL(whatsappURL) {
                            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                        }
                    }
                }
            } else {
                viewModel.generatePdf { completed in
                    viewModel.sharePdf(urlString: viewModel.pdfUrl, completion: { pdfData in
                        showActivityViewController(activities: [pdfData as Any])
                    })
                }
            }
        })
        .imageViewerOverlay(viewerShown: $showObservationImage, images: [imageData ?? ""])
        .imageViewerOverlay(viewerShown: $showObservationCloseImage, images: [imageData ?? ""])
        .pickerViewerOverlay(viewerShown: $showAlertForDeleteObservation, title: "Confirm Delete!!".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("Are you sure you want to delete this observation?")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        showAlertForDeleteObservation.toggle()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        showAlertForDeleteObservation.toggle()
                        deleteObservation()
                    } label: {
                        Text("Continue")
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)
            }
        }
    }
    
    var groupView: some View {
        HStack(spacing: 12) {
            WebUrlImage(url: viewModel.observationDetails.group?.groupImage.url, placeholderImage: Image(IC.PLACEHOLDER.GROUP))
                .frame(width: 28.5, height: 28.5)
                .cornerRadius(14.25)
            
            Text(viewModel.observationDetails.group?.groupName ?? "")
                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                .font(.medium(12))
            
            Text(viewModel.observationDetails.group?.groupCode ?? "")
                .foregroundColor(Color.Grey.SLATE)
                .font(.regular(12))
            
            Spacer()
        }
    }
    
    var observationImageView: some View {
        VStack {
            LeftAlignedHStack(
                Text("IMAGE & DESCRIPTION")
                    .foregroundColor(Color.Grey.BLUEY_GREY)
                    .font(.regular(12))
            )
            
            if viewModel.isGuestUser {
                if let imageDescription = viewModel.guestObservationDetails.imageDescription, imageDescription.count > 0 {
                    ForEach(0..<imageDescription.count, id: \.self) { index in
                        ImageView(count: index + 1, imageDescription: imageDescription[index], imageData: $imageData, showImages: $showObservationImage)
                            .padding(.top, 5)
                    }
                } else {
                    VStack {
                        Text("No Images Found")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(13))
                    }
                    .frame(height: 93.5)
                }
            } else {
                if let imageDescription = viewModel.observationDetails.imageDescription, imageDescription.count > 0 {
                    ForEach(0..<imageDescription.count, id: \.self) { index in
                        ImageView(count: index + 1, imageDescription: imageDescription[index], imageData: $imageData, showImages: $showObservationImage)
                            .padding(.top, 5)
                    }
                } else {
                    VStack {
                        Text("No Images Found")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(13))
                    }
                    .frame(height: 93.5)
                }
            }
        }
    }
    
    var reportedByView: some View {
        VStack(spacing: 12) {
            LeftAlignedHStack(
                Text("Reported By")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13))
            )
            
            LeftAlignedHStack(
                Text(viewModel.isGuestUser ? viewModel.guestObservationDetails.reportedBy : viewModel.observationDetails.reportedBy)
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.regular(15))
            )
        }
    }
    
    var reponsiblePersonView: some View {
        VStack(spacing: 12) {
            LeftAlignedHStack(
                Text("Responsible Person")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13))
            )
            
            if viewModel.isGuestUser {
                if viewModel.guestObservationDetails.responsiblePerson != "" {
                    LeftAlignedHStack(
                        Text(viewModel.guestObservationDetails.responsiblePerson)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(15))
                    )
                } else {
                    LeftAlignedHStack(
                        Text("NA")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(15))
                    )
                }
            } else {
                if viewModel.observationDetails.responsiblePersonName != "" {
                    LeftAlignedHStack(
                        Text(viewModel.observationDetails.responsiblePersonName ?? "")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(15))
                    )
                } else if viewModel.observationDetails.responsiblePersonName == "" {
                    if viewModel.observationDetails.responsiblePerson == nil {
                        LeftAlignedHStack(
                            Text("NA")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.regular(15))
                        )
                    } else {
                        VStack {
                            if viewModel.observationDetails.responsiblePerson?.userId == -2 {
                                VStack(spacing: 8) {
                                    LeftAlignedHStack(
                                        Text("Not Specified")
                                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                            .font(.medium(15))
                                    )
                                    
                                    LeftAlignedHStack(
                                        Text("Responsibility for all group members")
                                            .foregroundColor(Color.Grey.SLATE)
                                            .font(.regular(12))
                                    )
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 16)
                            } else if viewModel.observationDetails.responsiblePerson?.userId ?? -1 > 0 || viewModel.observationDetails.responsiblePerson?.userId == -3 {
                                HStack {
                                    if viewModel.observationDetails.responsiblePerson?.userId != -3 {
                                        WebUrlImage(url: viewModel.observationDetails.responsiblePerson?.image.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                                            .frame(width: 48.5, height: 48.5)
                                            .cornerRadius(24.25)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        LeftAlignedHStack(
                                            Text(viewModel.observationDetails.responsiblePerson?.name ?? "")
                                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                                .font(.medium(15))
                                        )
                                        
                                        LeftAlignedHStack(
                                            Text(viewModel.observationDetails.responsiblePerson?.email ?? "")
                                                .foregroundColor(Color.Grey.SLATE)
                                                .font(.regular(12))
                                        )
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                        .padding(.top, 16.5)
                    }
                }
            }
        }
    }
    
    var closeDetailsView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Observation Closeout")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(19))
                
                Spacer()
                
                Text(viewModel.isGuestUser ? viewModel.guestClosedTime : viewModel.closedTime)
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.regular(12))
            }
            
            HStack(spacing: 10) {
                Image(IC.PLACEHOLDER.CALENDER)
                
                Text(viewModel.isGuestUser ? viewModel.guestCloseDate : viewModel.closeDate)
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.regular(12))
                
                Spacer()
            }
            
            LeftAlignedHStack(
                Text("CLOSEOUT DESCRIPTION")
                    .foregroundColor(Color.Grey.BLUEY_GREY)
                    .font(.regular(12))
            )
            
            LeftAlignedHStack(
                Text(viewModel.isGuestUser ? viewModel.guestObservationDetails.closeDetails?.closeDescription ?? "" : viewModel.observationDetails.closeDetails?.closeDescription ?? "")
                    .foregroundColor(Color.Blue.BLUE_GREY)
                    .font(.light(12))
            )
            
            closeDetailsImageView
            
            if !viewModel.isGuestUser {
                LeftAlignedHStack(
                    Text("Closed By")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(13))
                )
                
                VStack {
                    HStack {
                        WebUrlImage(url: (viewModel.isGuestUser ? viewModel.guestObservationDetails.closeDetails?.closedBy?.image.url : viewModel.observationDetails.closeDetails?.closedBy?.image.url), placeholderImage: Image(IC.PLACEHOLDER.USER))
                            .frame(width: 48.5, height: 48.5)
                            .cornerRadius(24.25)
                        
                        VStack(spacing: 8) {
                            LeftAlignedHStack(
                                Text(viewModel.isGuestUser ? viewModel.guestObservationDetails.closeDetails?.closedBy?.name ?? "" : viewModel.observationDetails.closeDetails?.closedBy?.name ?? "")
                                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                    .font(.medium(15))
                            )
                            
                            LeftAlignedHStack(
                                Text(viewModel.isGuestUser ? viewModel.guestObservationDetails.closeDetails?.closedBy?.email ?? "" : viewModel.observationDetails.closeDetails?.closedBy?.email ?? "")
                                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                    .font(.regular(12))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
            }
        }
    }
    
    var closeDetailsImageView: some View {
        VStack {
            LeftAlignedHStack(
                Text("IMAGES")
                    .foregroundColor(Color.Grey.BLUEY_GREY)
                    .font(.regular(12))
            )
            
            if viewModel.isGuestUser {
                if let imageDescription = viewModel.guestObservationDetails.closeDetails?.imageDescription, imageDescription.count > 0 {
                    ForEach(0..<imageDescription.count, id: \.self) { index in
                        ImageView(count: index + 1, imageDescription: imageDescription[index], imageData: $imageData, showImages: $showObservationCloseImage)
                            .padding(.top, 5)
                    }
                } else {
                    VStack {
                        Text("No Images Found")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(13))
                    }
                    .frame(height: 93.5)
                }
            } else {
                if let imageDescription = viewModel.observationDetails.closeDetails?.imageDescription, imageDescription.count > 0 {
                    ForEach(0..<imageDescription.count, id: \.self) { index in
                        if imageDescription[index].image != "" {
                            ImageView(count: index + 1, imageDescription: imageDescription[index], imageData: $imageData, showImages: $showObservationCloseImage)
                                .padding(.top, 5)
                        }
                    }
                } else {
                    VStack {
                        Text("No Images Found")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(13))
                    }
                    .frame(height: 93.5)
                }
            }
            
        }
    }
    
    var CloseObservationButtonView: some View {
        VStack {
            Button {
                viewControllerHolder?.present(style: .overCurrentContext) {
                    if viewModel.isGuestUser {
                        CloseObservationContentView(viewModel: .init(observationId: viewModel.observationId, observationTitle: viewModel.guestObservationDetails.observationTitle, observationDescription: viewModel.guestObservationDetails.description, imageDescription: viewModel.guestObservationDetails.imageDescription, groupSpecified: false))
                    } else {
                        CloseObservationContentView(viewModel: .init(observationId: viewModel.observationId, observationTitle: viewModel.observationDetails.observationTitle, observationDescription: viewModel.observationDetails.description, groupImage: viewModel.observationDetails.group?.groupImage, groupName: viewModel.observationDetails.group?.groupName, groupCode: viewModel.observationDetails.group?.groupCode, imageDescription: viewModel.observationDetails.imageDescription, groupSpecified: viewModel.observationDetails.groupSpecified ?? false))
                    }
                }
            } label: {
                Text("Close Observation")
                    .foregroundColor(Color.white)
                    .font(.medium(16))
                    .frame(maxWidth: .infinity, minHeight: 45)
            }
            .background(Color.Blue.THEME)
            .cornerRadius(22.5)
        }
    }
    
    var DeleteObservationButtonView: some View {
        VStack {
            Button {
                showAlertForDeleteObservation.toggle()
            } label: {
                Text("Delete Observation")
                    .foregroundColor(Color.Red.SALMON)
                    .font(.medium(16))
            }
        }
    }
    
    func deleteObservation() {
        viewModel.deleteObservation { completed in
            NotificationCenter.default.post(name: .DELETE_OBSERVATION, object: nil)
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
    
    func generatePdf() {
        viewModel.generatePdf { completed in
            savePdf(urlString: viewModel.pdfUrl)
        }
    }
    
    
    
    func showActivityViewController(activities: [Any]) {
        
        let shareController: UIActivityViewController = {
            let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
            
            controller.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.openInIBooks,
                UIActivity.ActivityType.message,
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.copyToPasteboard,
                UIActivity.ActivityType.mail,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.markupAsPDF,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
                UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
            
            return controller
        }()
        
        viewControllerHolder?.present(shareController, animated: true, completion: {
        })
    }
    
    func savePdf(urlString:String) {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let pdfNameFromUrl = "ALNASR- \(Date().timeIntervalSince1970).pdf"
        let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
        do {
            try pdfData?.write(to: actualPath, options: .atomic)
            viewModel.toast = "pdf successfully saved!".successToast
        } catch {
            viewModel.toast = Toast.alert(subTitle: "Pdf could not be saved")
        }
    }
}

struct ObservationDetailContentView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationDetailContentView(viewModel: .init(observationId: -1))
    }
}

extension ObservationDetailContentView {
    struct ImageView: View {
        var count: Int
        var imageDescription: ImageData
        @Binding var imageData: String?
        @Binding var showImages: Bool
        
        var body: some View {
            VStack {
                VStack {
                    LeftAlignedHStack(
                        Text("Image \(count)")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.medium(13))
                    )
                    
                    WebUrlImage(url: imageDescription.image?.url)
                        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 93.5, alignment: .center)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.top, 13.5)
                        .onTapGesture {
                            imageData = imageDescription.image
                            showImages.toggle()
                        }
                    
                    LeftAlignedHStack(
                        Text("Description")
                            .foregroundColor(Color.Grey.BLUEY_GREY)
                            .font(.regular(12))
                    )
                        .padding(.top, 20.5)
                    
                    LeftAlignedHStack(
                        Text(imageDescription.description)
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.light(12))
                            .padding(.top, 13.5)
                    )
                }
                .padding(.vertical, 23.5)
                .padding(.horizontal, 22)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
        }
    }
}


