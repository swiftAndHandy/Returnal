//
//  Item+Images.swift
//  Returnal
//
//  Created by Andre Veltens on 09.12.25.
//

import Foundation
import UIKit

extension Item {
    func addImage(_ uiImage: UIImage, compression: CGFloat = 0.8) {
        guard let data = uiImage.jpegData(compressionQuality: compression) else { return }
        let asset = ImageAsset(data: data)
        self.images.append(asset)
    }
}
