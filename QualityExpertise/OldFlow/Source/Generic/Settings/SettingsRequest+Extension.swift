//
//  Settings+Extension.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import Foundation

extension SettingsRequest {
    struct SettingsParams: Encodable {
        let notificationType: SettingsType
    }
}
