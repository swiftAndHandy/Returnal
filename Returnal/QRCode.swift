//
//  QRCode.swift
//  Returnal
//
//  Created by Andre Veltens on 02.12.25.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

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
    
    static func printCode(item: Item, size: CGFloat = 200) {
        guard let image = drawCode(uuid: item.id) else { return }
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: size + 40, height: size + 100))
        
        let data = pdfRenderer.pdfData { (context) in
            context.beginPage()
            
            let qrRect = CGRect(x: 20, y: 50, width: size, height: size)
            image.draw(in: qrRect)
            
            let textRect = CGRect(x: 20, y: size + 40, width: size, height: 40)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            item.name.draw(in: textRect, withAttributes: attributes)
        }
        
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(item.name)_\(item.id).pdf")
        try? data.write(to: tmpURL)
        
        let printController = UIPrintInteractionController.shared
        printController.printingItem = tmpURL
        printController.present(animated: true)
    }
}
