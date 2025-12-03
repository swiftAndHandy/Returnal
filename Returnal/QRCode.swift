import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRCode {
    private struct RenderedEntry {
        let qr: UIImage
        let text: String
        let textHeight: CGFloat
        let fontSize: CGFloat
    }

    private static func prepareEntry(for item: Item, size: CGFloat) -> RenderedEntry? {
        guard let qr = drawCode(uuid: item.id) else { return nil }

        let qrPrintSize: CGFloat = size
        let maxTextHeight = qrPrintSize * 0.25
        var fontSize = max(qrPrintSize * 0.15, 5)

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byWordWrapping

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
            // if bounding still too high, reduce font and try again
            if bounding.height > maxTextHeight {
                fontSize -= 0.5
            } else {
                // found a font that fits
                break
            }
        } while fontSize > 5

        // Ensure final fontSize is not below minimum
        if fontSize < 5 { fontSize = 5 }

        // Recompute bounding with the final font size
        attributes[.font] = UIFont.systemFont(ofSize: fontSize)
        bounding = (item.name as NSString).boundingRect(
            with: CGSize(width: qrPrintSize, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )

        let finalHeight = ceil(bounding.height)

        return RenderedEntry(qr: qr, text: item.name, textHeight: finalHeight, fontSize: fontSize)
    }

    private static func renderPDF(entries: [RenderedEntry], columns: Int, size: CGFloat, spacing: CGFloat, addBorder: Bool) -> (data: Data, pageWidth: CGFloat, pageHeight: CGFloat) {

        let cellWidth = size + 20
        let cellHeight = size + 40
        let pageWidth = CGFloat(columns) * (cellWidth + spacing)
        let pageHeight: CGFloat = 800

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { ctx in
            var index = 0
            while index < entries.count {
                ctx.beginPage()

                for row in 0..<200 {
                    let y = CGFloat(row) * (cellHeight + spacing)
                    if y + cellHeight > pageHeight { break }

                    for col in 0..<columns {
                        guard index < entries.count else { break }

                        let entry = entries[index]
                        let x = CGFloat(col) * (cellWidth + spacing)

                        if addBorder {
                            let borderRect = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                            UIColor.black.setStroke()
                            UIBezierPath(rect: borderRect).stroke()
                        }

                        entry.qr.draw(in: CGRect(x: x + 10, y: y + 10, width: size, height: size))

                        let style = NSMutableParagraphStyle()
                        style.alignment = .center

                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: entry.fontSize),
                            .foregroundColor: UIColor.black,
                            .paragraphStyle: style
                        ]

                        let textRect = CGRect(
                            x: x + 10,
                            y: y + size + 12,
                            width: size,
                            height: entry.textHeight
                        )
                        (entry.text as NSString).draw(in: textRect, withAttributes: attributes)

                        index += 1
                    }
                }
            }
        }

        return (data, pageWidth, pageHeight)
    }

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
        guard let entry = prepareEntry(for: item, size: size) else { return }

        let rendered = renderPDF(entries: [entry], columns: 1, size: size, spacing: 20, addBorder: true)

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Returnal QR-Code"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo

        printController.printPageRenderer = QRCodePrintRenderer(
            pdfData: rendered.data,
            paperRect: CGRect(x: 0, y: 0, width: rendered.pageWidth, height: rendered.pageHeight)
        )
        printController.present(animated: true)
    }
    
    static func printCodes(items: [Item], size: CGFloat = 200, spacing: CGFloat = 20) {
        let entries = items.compactMap { prepareEntry(for: $0, size: size) }
        guard !entries.isEmpty else { return }

        let rendered = renderPDF(entries: entries, columns: 3, size: size, spacing: spacing, addBorder: true)

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Returnal QR-Codes"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo

        printController.printPageRenderer = QRCodePrintRenderer(
            pdfData: rendered.data,
            paperRect: CGRect(x: 0, y: 0, width: rendered.pageWidth, height: rendered.pageHeight)
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
