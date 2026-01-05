//
//  PDFDownloader.swift
//  ALNASR
//
//  Created by Amarjith B on 19/11/25.
//

import Foundation


class PDFDownloader: NSObject, URLSessionDownloadDelegate {

    var onProgress: ((Double) -> Void)?
    var onComplete: ((URL) -> Void)?
    var onError: ((Error) -> Void)?

    func downloadPDF(from url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.downloadTask(with: url).resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        onProgress?(progress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        onComplete?(location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error { onError?(error) }
    }
}
