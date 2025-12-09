//
//  ImageAsset.swift
//  Returnal
//
//  Created by Andre Veltens on 09.12.25.
//

import Foundation
import SwiftData

@Model
class ImageAsset {
    var id: UUID
    var data: Data
    
    init(data: Data) {
        self.id = UUID()
        self.data = data
    }
}
