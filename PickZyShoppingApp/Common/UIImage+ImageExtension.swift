//
//  UIImage+ImageExtension.swift
//  Shopor
//
//  Created by Ratheesh on 19/04/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import Photos

extension UIImage {
    static func from(info: [String : Any]) -> UIImage? {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            return editedImage
        }
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            return originalImage
        }

        var imageToBeReturned: UIImage?
        if let url = info[UIImagePickerControllerReferenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.isNetworkAccessAllowed = true
            manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: option, resultHandler: {(image: UIImage?, info: [AnyHashable : Any]?) in
                imageToBeReturned = image
            })
        }
        return imageToBeReturned
    }
}
