//
//  RepositoryManager.swift
// QualityExpertise
//
//  Created by Mac mini 10 on 21/08/20.
//  Copyright © 2020 Mac mini 10. All rights reserved.
//

import Foundation
import Alamofire

struct RepositoryManager {
    struct Connectivity {
        static var isConnected: Bool {
            return NetworkReachabilityManager()?.isReachable ?? false
        }
    }
        
    static func header(url: URL?, httpMethod: String?) -> HTTPHeaders {
        var header = HTTPHeaders()
        let headerKeys = Repository.Constants.Header.Key.self
        let headerValues = Repository.Constants.Header.Value.self

        if let accessToken = UserManager().auth?.access {
            header[headerKeys.AUTH_TOKEN] = headerValues.AUTH_TOKEN_BEARER + Constants.SPACE + accessToken
        }

        let time = NSDate().timeIntervalSince1970
        header[headerKeys.SIGNATURE] = RepositoryCrypt.signature(url: url, httpMethod: httpMethod, hashKey: Configurations.API.SECRET_KEY, timeStamp: time)
        header[headerKeys.TIMESTAMP] = "\(time)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        header[headerKeys.X_DEVICE_TOKEN] = NotificationManager.shared.firebaseToken ?? Constants.EMPTY_STRING
        header[headerKeys.X_DEVICE_TYPE] = Repository.Constants.DeviceType.iOS.rawValue
        header[headerKeys.LANGUAGE] = LocalizationService.shared.language.headerKey
        return header
    }
    
    private func processResponse(
        response: AFDataResponse<Any>,
        success:@escaping (_ response: Any) -> (),
        failure:@escaping (_ response: SystemError) -> ()
    ) {
        Log.debugPrint(response)
        
        switch response.result {
            
        case .failure(let error):
            let urlError = error.underlyingError as? URLError
            let code = urlError?.errorCode
            
            // Session expiration check
            if let urlError = urlError, code == Repository.ErrorCode.sessionTimeout.rawValue {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: ".SESSION_EXPIRED"),
                    object: nil,
                    userInfo: urlError.userInfo
                )
            }
            
            // Network errors (offline, lost connection)
            if !Configurations.isDebug {
                if code == Repository.ErrorCode.networkConnectionError.rawValue ||
                    code == Repository.ErrorCode.networkConnectionLost.rawValue {
                    
                    let theError = SystemError(
                        Repository.Constants.COMMON_NETWORK_ERROR_MESSAGE,
                        errorCode: code ?? -1,
                        response: response,
                        statusCode: error.responseCode
                    )
                    failure(theError)
                    return
                }
            }
            
            // 🔥 NEW: Try decoding backend error JSON
            if let data = response.data {
                if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {

                    // Select message based on environment
                    #if DEBUG
                    let displayMessage = apiError.response?.debugmessage ?? apiError.response?.message ?? apiError.message
                    #else
                    let displayMessage = apiError.response?.message ?? apiError.message
                    #endif

                    let theError = SystemError(
                        displayMessage,
                        type: .alert,
                        title: nil,
                        errorCode: apiError.errorCode,
                        response: apiError.response,
                        statusCode: response.response?.statusCode
                    )

                    failure(theError)
                    return
                }
            }

            
            // Fallback (old behavior)
            let fallback = SystemError(
                error.underlyingError?.localizedDescription ?? error.localizedDescription,
                errorCode: code ?? -1,
                response: response,
                statusCode: error.responseCode
            )
            failure(fallback)
            
            
        // ------------------------------------------------------------
        // SUCCESS CASE (unchanged)
        // ------------------------------------------------------------
            
        case .success(let responseData):
            guard let responseModel = RepositoryParser.parse(data: responseData, to: SuccessResponse.self) as? SuccessResponse else {
                
                let theError = SystemError(
                    Constants.COMMON_ERROR_MESSAGE,
                    errorCode: -1,
                    response: responseData
                )
                failure(theError)
                return
            }
            
            if responseModel.hasError {
                let theError = SystemError(
                    responseModel.message ?? Constants.COMMON_ERROR_MESSAGE,
                    errorCode: responseModel.errorCode,
                    response: responseData
                )
                
                if responseModel.errorCode == Repository.ErrorCode.sessionTimeout.rawValue {
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: ".SESSION_EXPIRED"),
                        object: nil,
                        userInfo: responseData as? [AnyHashable : Any]
                    )
                }
                
                failure(theError)
                return
            }
            
            let result = (responseData as! [String: Any])[Repository.Constants.Key.RESPONSE]
            success(result!)
        }
    }

    
    func call(endPoint: String,
              method: HttpMethod = .post,
              params: Parameters? = nil,
              headers: [String: Any]? = nil,
              user: User? = nil,
              interceptor: RepositoryRequestInterceptor? = RepositoryRequestInterceptor.shared,
              success: @escaping (_ response: Any) -> (),
              failure: @escaping (_ response: SystemError) -> ()) {
        
        let url = RepositoryHelper.URLMaker.apiURLStringFrom(endpoint: endPoint)
        let headers = RepositoryManager.header(url: URL(string: url), httpMethod: method.rawValue)
        
        Log.debugPrint("url = \(String(describing: url)) || param = \(String(describing: params))")
        
        // ✅ Start measuring before sending request
        let startTime = CFAbsoluteTimeGetCurrent()
        
        AF.request(url,
                   method: HTTPMethod(rawValue: method.rawValue),
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: headers,
                   interceptor: interceptor) { urlRequest in
            urlRequest.timeoutInterval = 20
        }
        .validate()
        .responseJSON(queue: .global(qos: .utility)) { response in
            // ✅ Calculate duration
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            Log.debugPrint("⏱ API \(endPoint) completed in \(duration)s")
            
            // ✅ Switch to main thread for UI updates
            DispatchQueue.main.async {
                processResponse(response: response, success: success, failure: failure)
            }
        }
    }

    
    
    func upload(
        endPoint: String,
        image: Data,
        withName: String,
        fileName: String,
        params: [String: Any]? = nil,
        interceptor: RepositoryRequestInterceptor? = nil,
        success:@escaping (_ response: Any) -> (),
        failure:@escaping (_ response: SystemError) -> ()) {
        
        let url = RepositoryHelper.URLMaker.apiURLStringFrom(endpoint: endPoint)
        var headers = RepositoryManager.header(url: URL(string: url), httpMethod: HTTPMethod.post.rawValue)
        headers[Repository.Constants.Header.Key.CONTENT_TYPE] = Repository.Constants.Header.Value.CONTENT_TYPE_MULTIPART_FORM_DATA

        Log.debugPrint("url = \(String(describing: url)) || param = \(String(describing: params))")
        
        AF.upload(multipartFormData: {multipart in
            if let parameters = params {
                for (key, value) in parameters {
                    multipart.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            multipart.append(image, withName: withName, fileName: fileName, mimeType: Repository.Constants.Header.Value.IMAGE_UPLOAD_MIME_TYPE)
        }, to: url, method: .post, headers: headers, interceptor: interceptor ?? RepositoryRequestInterceptor())
            .responseJSON { (response) in
                processResponse(response: response, success: success, failure: failure)
            }
    }
}


extension RepositoryManager {
    struct APIErrorResponse: Codable {
        let hasError: Bool
        let errorCode: Int
        let message: String
        let response: Inner?
        
        struct Inner: Codable {
            let message: String?
            let debugmessage: String?
        }
    }
}
