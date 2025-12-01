//
//  QRCode.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCode: View {
    let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "unknown"
    let uuid: UUID

    var body: some View {
        if let image = generateQRCode(uuid: uuid) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Text("QR konnte nicht erzeugt werden.")
        }
    }
    
    init(for uuid: UUID) {
        self.uuid = uuid
    }

    private func generateQRCode(uuid: UUID) -> UIImage? {
        let combined = "\(bundleIdentifier)_\(uuid.uuidString)"
        let data = Data(combined.utf8)

        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        guard let outputImage = filter.outputImage?.transformed(by: transform) else {
            print("failed to generate qr code")
            return nil
        }

        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            print("\(combined)")
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
        
    }
}


#Preview {
    QRCode(for: UUID())
}
