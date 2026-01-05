//
//  RepositoryRequestInterceptor.swift
// QualityExpertise
//
//  Created by Vivek M on 16/07/21.
//

import Foundation
import Alamofire

class RepositoryRequestInterceptor: RequestInterceptor {
    let retryLimit = 3
    let retryDelay: TimeInterval = 10
    var isRefreshTokenLoading = false
    static let shared = RepositoryRequestInterceptor()

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let token = UserManager().auth?.access {
            let bearerToken = Repository.Constants.Header.Value.AUTH_TOKEN_BEARER + Constants.SPACE + token
            urlRequest.setValue(bearerToken, forHTTPHeaderField: Repository.Constants.Header.Key.AUTH_TOKEN)
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        Log.print(response ?? "")
        //Retry for 401 status codes
        if let statusCode = response?.statusCode,
           statusCode == Repository.ErrorCode.sessionTimeout.rawValue,
            request.retryCount <= retryLimit {
            Log.print("\nretried; retry count: \(request.retryCount)\n")
            guard !self.isRefreshTokenLoading else {
                completion(.retryWithDelay(TimeInterval(0.5)))
                return
            }
            
            refreshToken { isSuccess in
                isSuccess ? completion(.retry) : completion(.doNotRetry)
            }
        } else {
            return completion(.doNotRetry)
        }
    }
    
    func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let refresh = UserManager().auth?.refresh else {
            UserManager.logout()
            completion(true)
            return
        }
        
        RefreshTokenRequest
            .refreshToken(refresh: refresh)
            .makeCall(responseType: Auth.self) { isLoading in
                self.isRefreshTokenLoading = isLoading
            } success: { auth in
                UserManager.saveLogined(auth: auth)
                completion(true)
            } failure: { error in
                switch error.errorCode {
                case Repository.ErrorCode.sessionTimeout.rawValue, Repository.ErrorCode.unauthorizedAccess.rawValue:
                    UserManager.logout()
                    completion(true)
                    return
                default: break
                }

                switch error.statusCode {
                case Repository.ErrorCode.sessionTimeout.rawValue, Repository.ErrorCode.unauthorizedAccess.rawValue:
                    UserManager.logout()
                    completion(true)
                    return
                default: break
                }
                
                completion(false)
            }
    }
}
