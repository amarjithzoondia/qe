//
//  RequestProtocol.swift
// QualityExpertise
//
//  Created by Developer on 03/08/21.
//

import Foundation
import Alamofire

protocol RequestProtocol {
    var repository: Repository? { get }
    var version: RespositoryVersion? { get }
    var folderPath: RequestFolder? { get }
    var endpoint: String { get }
    var method : HttpMethod { get }
    var params: Encodable? { get }
    var imageData: Data? { get }
    func makeCall<T: Decodable>(responseType: T.Type, loading: @escaping (Bool) -> (), success: @escaping (T) -> (), failure: @escaping (SystemError) -> ())
    func upload<T: Decodable>(responseType: T.Type, loading: @escaping (Bool) -> (), success: @escaping (T) -> (), failure: @escaping (SystemError) -> ())

}

extension RequestProtocol {
    var version: RespositoryVersion? { nil }
    
    var method: HttpMethod { .post }
    
    func makeCall<T: Decodable>(responseType: T.Type, loading: @escaping (Bool) -> (), success: @escaping (T) -> (), failure: @escaping (SystemError) -> ()) {
        loading(true)
        var endpoint = ""
        if let repository = repository?.rawValue {
            endpoint = endpoint + repository + "/"
        }
        let API = Configurations.API.SERVICE_FOLDER
        endpoint = endpoint + API + "/"
        if let version = version?.rawValue {
            endpoint = endpoint + version + "/"
        }
        if let folderPath = folderPath?.rawValue {
            endpoint = endpoint + folderPath + "/"
        }
        endpoint = endpoint + self.endpoint
        endpoint = endpoint.replacingOccurrences(of: "//", with: "/")
        RepositoryHelper.request(endPoint: endpoint, method: method,
                               parameter: params,
                               responseCallBackOf: responseType) { (response) in
            loading(false)
            success(response)
        } failure: { (error) in
            loading(false)
            failure(error)
        }
    }
    
    func upload<T: Decodable>(responseType: T.Type, loading: @escaping (Bool) -> (), success: @escaping (T) -> (), failure: @escaping (SystemError) -> ()) {
        loading(true)
        var endpoint = ""
        if let repository = repository?.rawValue {
            endpoint = endpoint + repository + "/"
        }
        let API = Configurations.API.SERVICE_FOLDER
        endpoint = endpoint + API + "/"
        if let version = version?.rawValue {
            endpoint = endpoint + version + "/"
        }
        if let folderPath = folderPath?.rawValue {
            endpoint = endpoint + folderPath + "/"
        }
        endpoint = endpoint + self.endpoint
        endpoint = endpoint.replacingOccurrences(of: "//", with: "/")
        
        RepositoryHelper.upload(endPoint: endpoint, image: imageData!, parameter: params, responseCallBackOf: responseType) { (response) in
            loading(false)
            success(response)
        } failure: { (error) in
            loading(false)
            failure(error)
        }
    }
    
    var imageData: Data? { nil }
}
