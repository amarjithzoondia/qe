//
//  SpCrypt.swift
// QualityExpertise
//
//  Created by Vivek M on 27/08/20.
//

import Foundation
import CommonCrypto

extension String {
    // ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}


public struct RepositoryCrypt {

    public static func signature(urlRequest: URLRequest, hashKey key: String, timeStamp: TimeInterval) -> String? {
        guard let url = urlRequest.url, let host = url.host, let httpMethod = urlRequest.httpMethod else { return nil }
        let timeStamp = "\(timeStamp)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        let base = "\(host)::API::\(url.path)::\(httpMethod)::\(timeStamp)"
        print("Signature Base: \(base)")
        var signature = base.hmac(key: key)
        signature = signature.replacingOccurrences(of: "+", with: "-")
        signature = signature.replacingOccurrences(of: "/", with: "_")
        signature = signature.trimmingCharacters(in: .whitespacesAndNewlines)
        return signature
    }
    
    public static func signature(url: URL?, httpMethod: String?, hashKey key: String, timeStamp: TimeInterval) -> String? {
        guard let url = url, let host = url.host, let httpMethod = httpMethod else { return nil }
        let timeStamp = "\(timeStamp)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        let base = "\(host)::API::\(url.path)::\(httpMethod)::\(timeStamp)"
        print("Signature Base: \(base)")
        var signature = base.hmac(key: key)
        signature = signature.replacingOccurrences(of: "+", with: "-")
        signature = signature.replacingOccurrences(of: "/", with: "_")
        signature = signature.trimmingCharacters(in: .whitespacesAndNewlines)
        return signature
    }
    
}

extension URLRequest {
    
    public func signature(hashKey key: String, timeStamp: TimeInterval) -> String? {
        return RepositoryCrypt.signature(urlRequest: self, hashKey: key, timeStamp: timeStamp)
    }
    
}


extension String {
    
    enum CryptoAlgorithm {
        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
        
        var HMACAlgorithm: CCHmacAlgorithm {
            var result: Int = 0
            switch self {
            case .MD5:      result = kCCHmacAlgMD5
            case .SHA1:     result = kCCHmacAlgSHA1
            case .SHA224:   result = kCCHmacAlgSHA224
            case .SHA256:   result = kCCHmacAlgSHA256
            case .SHA384:   result = kCCHmacAlgSHA384
            case .SHA512:   result = kCCHmacAlgSHA512
            }
            return CCHmacAlgorithm(result)
        }
        
        var digestLength: Int {
            var result: Int32 = 0
            switch self {
            case .MD5:      result = CC_MD5_DIGEST_LENGTH
            case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
    }
    
    func hmac(algorithm: CryptoAlgorithm = .SHA1, key: String) -> String {
        let str = self.cString(using: .utf8)
        let strLen = Int(self.lengthOfBytes(using: .utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: .utf8)
        let keyLen = Int(key.lengthOfBytes(using: .utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        let data = Data(bytes: result, count: 16)
        let encodedString = data.base64EncodedString()
        
        result.deallocate()
        return encodedString
    }
    
    private func hexStringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        
        return String(hash)
    }
    
}
