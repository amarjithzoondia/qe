//
//  RepositoryHelper.swift
// QualityExpertise
//
//  Created by Vivek M on 02/03/21.
//

import Foundation

struct RepositoryHelper {
    struct URLMaker {
        static func apiURLStringFrom(endpoint: String) -> String {
            Configurations.API.SERVICE_ROOT + endpoint
        }
        
        static func googleQRCodeURL(for string: String) -> URL? {
            return URL(string: "https://chart.googleapis.com/chart?cht=qr&chl=\(string)&chs=137x137")
        }
    }
    
    static func request<T: Decodable>(endPoint: String,
                                      method: HttpMethod,
                                      parameter datas: Encodable? = nil,
                                      responseCallBackOf type: T.Type,
                                      user: User? = nil,
                                      success: @escaping (T) -> (),
                                      failure: @escaping (SystemError) -> ()) {
        
        var finalEndpoint = endPoint
        var bodyParams: [String: Any]? = nil

        if let encodedParams = datas?.dictionary {
            if method == .get {
                var urlComponents = URLComponents(string: endPoint)
                urlComponents?.queryItems = encodedParams.map {
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
                if let urlWithParams = urlComponents?.url?.absoluteString {
                    finalEndpoint = urlWithParams
                }
            } else {
                bodyParams = encodedParams
            }
        }

        RepositoryManager().call(endPoint: finalEndpoint,
                                 method: method,
                                 params: bodyParams,
                                 user: user) { response in
            processSuccessResponse(response,
                                   responseCallBackOf: type,
                                   success: success,
                                   failure: failure)
        } failure: { serviceError in
            failure(serviceError)
        }
    }
    

    
    static func upload<T: Decodable>(endPoint: String,
                                     image: Data,
                                     parameter datas: Encodable? = nil,
                                     responseCallBackOf type: T.Type,
                                     user: User? = nil,
                                     success: @escaping (T) -> (),
                                     failure: @escaping (SystemError) -> ()) {
        let params = datas?.dictionary
        let name = UUID().uuidString
        RepositoryManager().upload(endPoint: endPoint, image: image, withName: "image", fileName: name + ".png", params: params) { (response) in
            processSuccessResponse(response, responseCallBackOf: type, success: success, failure: failure)
        } failure: { serviceError in
            failure(serviceError)
        }
    }
    
    private static func processSuccessResponse<T: Decodable>(_ response: Any,
                                                             responseCallBackOf type: T.Type,
                                               success: @escaping (T) -> (),
                                               failure: @escaping (SystemError) -> ()) {
        if let response = response as? String {
            success(response as! T)
            return
        } else {
            
            do {
                if let jsonData = try? JSONSerialization.data(withJSONObject: response) {
                    let decoder = JSONDecoder()
                    success(try decoder.decode(type, from: jsonData))
                    return
                }
            } catch let err {
                Log.debugPrint(Repository.Constants.PARSING_ERROR_MESSAGE, err)
                if Configurations.isDebug {
                    failure(SystemError(Repository.Constants.PARSING_ERROR_MESSAGE,
                                        errorCode: Repository.ErrorCode.parsingError.rawValue,
                                        response: response)
                    )
                    return
                }
            }
        }
        
        failure(SystemError(Repository.Constants.COMMON_ERROR_MESSAGE,
                            errorCode: Repository.ErrorCode.parsingError.rawValue,
                                 response: response)
        )
    }
}
