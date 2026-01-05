//
//  DownloadManager.swift
// QualityExpertise
//
//  Created by Developer on 06/07/22.
//

import Foundation
import Alamofire


class DownloadManager {
    
   static func downloadfromURL(url: String, completion: @escaping (Data?)->()) {
        AF.download(url).responseData { data in
            completion(data.value)
        }
    }
}
