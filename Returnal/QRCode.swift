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
        guard let qrImage = drawCode(uuid: item.id) else { return }

        // Desired QR code print size in points (can be scaled to mm/inches)
        let qrPrintSize: CGFloat = size

        // Paragraph style
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byWordWrapping

        // Dynamic font size proportional to QR code
        let maxTextHeight = qrPrintSize * 0.25
        var fontSize = max(qrPrintSize * 0.15, 5)
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: style
        ]

        var bounding: CGRect = .zero
        repeat {
            attributes[.font] = UIFont.systemFont(ofSize: fontSize)
            bounding = (item.name as NSString).boundingRect(
                with: CGSize(width: qrPrintSize, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )
            fontSize -= 0.5
        } while bounding.height > maxTextHeight && fontSize > 5

        let textHeight = ceil(bounding.height)
        let totalWidth = qrPrintSize
        let totalHeight = qrPrintSize + textHeight + 8 // small padding

        // Create a PDF of exactly the QR+Text size
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            qrImage.draw(in: CGRect(x: 0, y: 0, width: qrPrintSize, height: qrPrintSize))
            let textRect = CGRect(x: 0, y: qrPrintSize + 4, width: qrPrintSize, height: textHeight)
            (item.name as NSString).draw(in: textRect, withAttributes: attributes)
        }

        // Save temp PDF
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(item.name)_\(item.id).pdf")
        try? data.write(to: url)

        // Print with custom PageRenderer to avoid auto-scaling
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Returnal QR-Code"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo

        printController.printPageRenderer = QRCodePrintRenderer(pdfData: data, paperRect: CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
        printController.present(animated: true)
    }
    
    static func printCodes(items: [Item], size: CGFloat = 200, spacing: CGFloat = 20) {
        guard !items.isEmpty else { return }

        // Prepare all QR images + text sizes
        var entries: [(qr: UIImage, text: String, textHeight: CGFloat)] = []

        for item in items {
            guard let qr = drawCode(uuid: item.id) else { continue }

            // Paragraph style
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            style.lineBreakMode = .byWordWrapping

            let qrPrintSize: CGFloat = size
            let maxTextHeight = qrPrintSize * 0.25
            var fontSize = max(qrPrintSize * 0.15, 5)
            var attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.black,
                .paragraphStyle: style
            ]

            var bounding: CGRect = .zero
            repeat {
                attributes[.font] = UIFont.systemFont(ofSize: fontSize)
                bounding = (item.name as NSString).boundingRect(
                    with: CGSize(width: qrPrintSize, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                fontSize -= 0.5
            } while bounding.height > maxTextHeight && fontSize > 5

            let finalHeight = ceil(bounding.height)
            entries.append((qr, item.name, finalHeight))
        }

        if entries.isEmpty { return }

        // Width is always the QR size
        let width = size

        // Total height = sum of entries (qr + text + padding) + spacing between blocks
        let totalHeight: CGFloat = entries.reduce(0) { acc, entry in
            acc + size + entry.textHeight + 8 + spacing
        }

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: width, height: totalHeight))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()

            var offsetY: CGFloat = 0

            for entry in entries {
                // Draw QR
                entry.qr.draw(in: CGRect(x: 0, y: offsetY, width: size, height: size))

                // Draw Text
                let style = NSMutableParagraphStyle()
                style.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: max(size * 0.15, 5)),
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: style
                ]

                let textRect = CGRect(x: 0, y: offsetY + size + 4, width: size, height: entry.textHeight)
                (entry.text as NSString).draw(in: textRect, withAttributes: attributes)

                // Move down
                offsetY += size + entry.textHeight + 8 + spacing
            }
        }

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Returnal QR-Codes"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo

        printController.printPageRenderer = QRCodePrintRenderer(
            pdfData: data,
            paperRect: CGRect(x: 0, y: 0, width: width, height: totalHeight)
        )
        printController.present(animated: true)
    }
}

// Custom Page Renderer to print the PDF at exact size
class QRCodePrintRenderer: UIPrintPageRenderer {
    let pdfData: Data
    let contentRect: CGRect
    let margin: CGFloat = 20

    init(pdfData: Data, paperRect: CGRect) {
        self.pdfData = pdfData
        self.contentRect = paperRect
        super.init()

        let expanded = paperRect.insetBy(dx: -margin, dy: -margin)

        self.setValue(NSValue(cgRect: expanded), forKey: "paperRect")
        self.setValue(NSValue(cgRect: expanded), forKey: "printableRect")
    }

    override func drawPage(at pageIndex: Int, in printableRect: CGRect) {
        guard let pdf = CGPDFDocument(CGDataProvider(data: pdfData as CFData)!) else { return }
        guard let page = pdf.page(at: pageIndex + 1) else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()

        // Flip coordinate system
        context.translateBy(x: 0, y: printableRect.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // Target size (original PDF bounds)
        let targetWidth = contentRect.width
        let targetHeight = contentRect.height

        // Final position: top-left with margin
        let drawX: CGFloat = margin
        let drawY: CGFloat = printableRect.height - targetHeight - margin

        // Apply translation for drawing
        context.translateBy(x: drawX, y: drawY)

        // Scale PDF to exact size
        let pdfBox = page.getBoxRect(.mediaBox)
        let scaleX = targetWidth / pdfBox.width
        let scaleY = targetHeight / pdfBox.height
        context.scaleBy(x: scaleX, y: scaleY)

        context.drawPDFPage(page)

        context.restoreGState()
    }

    override var numberOfPages: Int {
        return 1
    }
}
