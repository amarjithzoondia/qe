//
//  RepositoryConstant.swift
// ALNASR
//
//  Created by Vivek M on 03/03/21.
//

import Foundation

extension Repository {
    struct Constants {
        
        static let COMMON_ERROR_MESSAGE = "Something Went Wrong!!"
        static let PARSING_ERROR_MESSAGE = "\(COMMON_ERROR_MESSAGE) - Parsing failed"
        
        static let COMMON_NETWORK_ERROR_MESSAGE = "Something is temporarily wrong with your network connection! Try again."
        
        enum DeviceType: String {
            case iOS = "2"
        }
        
        enum ContentType: String {
            case json = "application/json"
        }

        struct Header {
            struct Key {
                static let AUTH_TOKEN = "Authorization"
                static let SIGNATURE = "signature"
                static let TIMESTAMP = "timestamp"
                static let X_DEVICE_TOKEN = "X-Device-Token"
                static let X_DEVICE_TYPE = "X-Device-Type"
                static let CONTENT_TYPE = "Content-Type"
                static let USER_AGENT = "User-Agent"
            }
            
            struct Value {
                static let AUTH_TOKEN_BEARER = "Bearer"
                static let CONTENT_TYPE_MULTIPART_FORM_DATA = "multipart/form-data"
                static let IMAGE_UPLOAD_MIME_TYPE = "image/png"

                struct Language {
                    static let EN = "en"
                }
            }
        }
        
        struct Key {
            static let RESPONSE = "response"
        }
        
        struct Value {
            static let DEVICE_TYPE = "1"
            static let LANGUAGE = "en"
        }
    }
    
    static func unknownError() -> SystemError {
        if !RepositoryManager.Connectivity.isConnected {
            return SystemError(Repository.Constants.COMMON_NETWORK_ERROR_MESSAGE,
                               errorCode: Repository.ErrorCode.networkConnectionLost.rawValue)
        }
        
        return SystemError(Constants.COMMON_NETWORK_ERROR_MESSAGE,
                           errorCode: Repository.ErrorCode.unknown.rawValue,
                           response: nil)
    }
} 
