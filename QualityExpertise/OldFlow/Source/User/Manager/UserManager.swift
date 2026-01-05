//
//  UserManager.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//
import SwiftUI

struct UserManager {
    //MARK: - Getters
    static let LOGINED_AUTH = "LOGINED_AUTH"
    static let CHECKOUT_USER = "CHECKOUT_USER"
    static let LOGINED_USER = "LOGINED_USER"
    static let SETTINGS = "SETTINGS"
    static let OBSERVATION_DRAFT = "OBSERVATION_DRAFT"
    static let USER_DETAILS = "USER_DETAILS"
    static var instance = UserManager()
    var user: User? = UserManager.getLoginedUser()
    var auth: Auth? = UserManager.getLoginedAuth()
    var isLogined = getLoginedUser() != nil
    var settings = UserManager.getSettings()
    var notificationUnReadCount: Int = 0
    var pendingActionsCount: Int = 0
    var userDetails: UserDetails? = nil
    
    static func getCheckOutUser() -> CheckOutUser? {
        let defaults = UserDefaults.standard
        if let savedPerson = defaults.object(forKey: CHECKOUT_USER) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(CheckOutUser.self, from: savedPerson) {
                return loadedPerson
            }
        }
        return nil
    }
    
    static func getLoginedUser() -> User? {
        let defaults = UserDefaults.standard
        if let savedPerson = defaults.object(forKey: LOGINED_USER) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(User.self, from: savedPerson) {
                return loadedPerson
            }
        }
        return nil
    }
    
    static func getLoginedAuth() -> Auth? {
        let defaults = UserDefaults.standard
        if let savedAuth = defaults.object(forKey: LOGINED_AUTH) as? Data {
            let decoder = JSONDecoder()
            if let auth = try? decoder.decode(Auth.self, from: savedAuth) {
                return auth
            }
        }
        return nil
    }
    
    static func getSettings() -> SettingsModel? {
        let defaults = UserDefaults.standard
        if let settings = defaults.object(forKey: SETTINGS) as? Data {
            let decoder = JSONDecoder()
            if let loadedSettings = try? decoder.decode(SettingsModel.self, from: settings) {
                return loadedSettings
            }
        }
        return nil
    }
    
    static func getUserDetails() -> UserDetails? {
        let defaults = UserDefaults.standard
        if let userDetails = defaults.object(forKey: USER_DETAILS) as? Data {
            let decoder = JSONDecoder()
            if let loadedSettings = try? decoder.decode(UserDetails.self, from: userDetails) {
                return loadedSettings
            }
        }
        return nil
    }
    
    static func getObservationDraftList() -> [ObservationDraftData] {
        var draftDatas: [ObservationDraftData]?
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: OBSERVATION_DRAFT) as? Data {
            draftDatas  = try? PropertyListDecoder().decode([ObservationDraftData].self, from: data)
            return draftDatas ?? [ObservationDraftData]()
        }
        return []
    }
    
    static func saveCheckOutUser(user: CheckOutUser) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(user)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: CHECKOUT_USER)
        } catch let error {
            Log.print(error)
        }
    }
    
    static func saveUserDetails(userDetails: UserDetails) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(userDetails)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: USER_DETAILS)
        } catch let error {
            Log.print(error)
        }
    }
    
    static func saveLogined(user: User) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(user)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: LOGINED_USER)
        } catch let error {
            Log.print(error)
        }
    }
    
    static func saveLogined(auth: Auth) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(auth)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: LOGINED_AUTH)
        } catch let error {
            Log.print(error)
        }
    }
    
    static func saveSettings(settings: SettingsModel) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(settings)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: SETTINGS)
        } catch let error {
            Log.print(error)
        }
    }
    
    static func saveObservationDraftData(datas: [ObservationDraftData]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(datas), forKey: OBSERVATION_DRAFT)
        UserDefaults.standard.synchronize()
    }
    
    static func logout(gotoLoginScreen: Bool = true) {
        guard UserManager().isLogined else { return }
        func resetAppUserDefaults() {
            UserDefaults.standard.removeObject(forKey: LOGINED_USER)
            UserDefaults.standard.removeObject(forKey: LOGINED_AUTH)
            UserDefaults.standard.removeObject(forKey: CHECKOUT_USER)
            UserDefaults.standard.removeObject(forKey: USER_DETAILS)
            LocalizationService.shared.language = .english
            UserManager.instance.notificationUnReadCount = 0
            UserManager.instance.pendingActionsCount = 0
        }
        var rootViewController: UIViewController? = nil
        if gotoLoginScreen {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            rootViewController = windowScene?.windows.first?.rootViewController
        }
        if let rootViewController = rootViewController {
            rootViewController.dismiss(animated: true, completion: {
                resetAppUserDefaults()
                if gotoLoginScreen {
                    NotificationCenter.default.post(name: .RELAUNCH_APP, object: nil)
                }
            })
        } else {
            resetAppUserDefaults()
            if gotoLoginScreen {
                NotificationCenter.default.post(name: .RELAUNCH_APP, object: nil)
            }
        }
    }
}
