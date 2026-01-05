//
//  CreateImageViewModel.swift
// ALNASR
//
//  Created by developer on 07/02/22.
//

import UIKit.UIImage

class CreateImageViewModel: BaseViewModel, ObservableObject {
    internal init(item: ImageData, index: Int) {
        self.item = item
        self.index = index
    }
    
    @Published var item: ImageData
    @Published var index: Int
    var imageTitleText: String {
        return "Image" + Constants.SPACE + ((index + 1).string)
    }
    
    func upload(image: UIImage?,
                loading: @escaping (Bool) -> (),
                completed: @escaping (String) -> (),
                failure: @escaping () -> ()) {
        
        do {
            guard let image = image else {
                throw SystemError("Image".localizedString(), type: .validation)
            }
            
            ImageUploadRequest
                .observationImage(image: image)
                .upload(responseType: ImageUploadResponse.self) { (isLoading) in
                    loading(isLoading)
                } success: { (response) in
                    completed(response.imageUrl)
                } failure: { (error) in
                    failure()
                }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
}

