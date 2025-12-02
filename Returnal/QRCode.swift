//
//  QRCode.swift
//  Returnal
//
//  Created by Andre Veltens on 02.12.25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCode {
    static func drawCode(uuid: UUID) -> UIImage? {
        let combined = "returnal://open?uuid=\(uuid)"
        let data = Data(combined.utf8)

        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let outputImage = filter.outputImage?.transformed(by: transform) else {
            return nil
        }

        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
