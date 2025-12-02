//
//  QRCodeView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftUI

struct QRCodeView: View {
    let uuid: UUID
    let size: CGFloat?

    var body: some View {
        if let image = QRCode.drawCode(uuid: uuid) {
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
}


#Preview {
    QRCodeView(for: UUID())
}
