//
//  QRCodeView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftUI

struct QRCodeView: View {
    let size: CGFloat?
    let uiImage: UIImage

    var body: some View {
        Image(uiImage: uiImage)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }

    init(for qrCode: UIImage, size: CGFloat? = nil) {
        self.uiImage = qrCode
        self.size = size
    }
}


#Preview {
    let qrCode = QRCode.drawCode(uuid: UUID())
    QRCodeView(for: qrCode ?? UIImage())
}
