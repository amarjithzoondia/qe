//
//  CreateInspectionImageViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 05/06/25.
//

import UIKit.UIImage

class CreateInspectionImageViewModel: BaseViewModel, ObservableObject {
    internal init(item: ImageData, index: Int) {
        self.item = item
        self.index = index
    }
    
    @Published var item: ImageData
    @Published var index: Int
    var imageTitleText: String {
        return "image".localizedString() + Constants.SPACE + ((index + 1).string)
    }
    
    func upload(image: UIImage?,
                loading: @escaping (Bool) -> (),
                completed: @escaping (String) -> (),
                failure: @escaping () -> ()) {
        
        do {
            guard let image = image else {
                throw SystemError("image".localizedString(), type: .validation)
            }
            
            ImageUploadRequest
                .inspectionImage(image: image)
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
