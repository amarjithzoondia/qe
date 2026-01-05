//
//  ThemeUploadFieldSkeltonView.swift
// QualityExpertise
//
//  Created by developer on 20/01/22.
//

import SwiftUI

enum UploadStatus: Equatable {
    case pending
    case inProgress
    case completed(url: String)
    case failure
    
    var view: some View {
        switch self {
        case .pending:
            return AnyView(Image(IC.ACTIONS.UPLOAD.PENDING))
        case .inProgress:
            return AnyView(ProgressView())
        case .completed(_):
            return AnyView(Image(IC.ACTIONS.UPLOAD.COMPLETED))
        case .failure:
            return AnyView(Image(systemName: "arrow.clockwise").foregroundColor(Color.Red.LIGHT))
        }
    }
    
    func hintText(forItemText text: String?) -> String {
        switch self {
        case .pending:
            if let text = text {
                return "UPLOAD".localizedString() + Constants.SPACE + text
            }
            return "UPLOAD".localizedString()
        case .inProgress:
            if let text = text {
                return "UPLOADING".localizedString() + Constants.SPACE + text
            }
            return "UPLOADING".localizedString()
        case .completed(_):
            if let text = text {
                return "UPLOADED".localizedString() + Constants.SPACE + text
            }
            return "UPLOADED".localizedString()
        case .failure:
            if let text = text {
                return "UPLOAD_FAILED".localizedString() + Constants.SPACE + text
            }
            return "UPLOAD_FAILED".localizedString()
        }
    }
    
    var actionText: String? {
        switch self {
        case .pending:
            return "CAPTURE".localizedString()
        case .inProgress:
            return nil
        case .completed(_):
            return "REMOVE".localizedString()
        case .failure:
            return "RETRY".localizedString()
        }
    }
}
