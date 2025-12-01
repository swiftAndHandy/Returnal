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
    let size: CGFloat?

    var body: some View {
        if let image = generateQRCode(uuid: uuid) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Text("QR konnte nicht erzeugt werden.")
        }
    }

    init(for uuid: UUID, size: CGFloat? = nil) {
        self.uuid = uuid
        self.size = size
    }

    private func generateQRCode(uuid: UUID) -> UIImage? {
        let combined = "\(bundleIdentifier)_\(uuid.uuidString)"
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


#Preview {
    QRCode(for: UUID())
}
