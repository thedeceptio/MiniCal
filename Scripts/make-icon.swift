import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Draws the MiniCal app icon: a calendar page with a red header band and a
// coarse dot grid standing in for the month, one dot highlighted like "today".
// Everything is proportional to `size` so each PNG is drawn natively rather
// than downsampled from 1024 — small sizes stay crisp that way.
func drawIcon(size: CGFloat, context ctx: CGContext) {
    let s = size

    // Apple's macOS icon grid: the rounded square is ~80.5% of the canvas.
    let inset = s * 0.0977
    let side = s * 0.8047
    let rect = CGRect(x: inset, y: inset, width: side, height: side)
    let radius = side * 0.2251

    let squircle = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Soft drop shadow, skipped at tiny sizes where it just muddies the edge.
    if s >= 64 {
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.012),
                      blur: s * 0.028,
                      color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.28))
        ctx.addPath(squircle)
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        ctx.fillPath()
        ctx.restoreGState()
    }

    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()

    // Page body: near-white with a faint vertical gradient.
    let space = CGColorSpaceCreateDeviceRGB()
    let bodyGradient = CGGradient(colorsSpace: space, colors: [
        CGColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1),
        CGColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1),
    ] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(bodyGradient,
                           start: CGPoint(x: 0, y: rect.maxY),
                           end: CGPoint(x: 0, y: rect.minY),
                           options: [])

    // Header band across the top, in calendar red.
    let headerH = side * 0.28
    let headerRect = CGRect(x: rect.minX, y: rect.maxY - headerH, width: side, height: headerH)
    let headerGradient = CGGradient(colorsSpace: space, colors: [
        CGColor(red: 1.00, green: 0.31, blue: 0.27, alpha: 1),
        CGColor(red: 0.90, green: 0.16, blue: 0.16, alpha: 1),
    ] as CFArray, locations: [0, 1])!
    ctx.saveGState()
    ctx.clip(to: headerRect)
    ctx.drawLinearGradient(headerGradient,
                           start: CGPoint(x: 0, y: headerRect.maxY),
                           end: CGPoint(x: 0, y: headerRect.minY),
                           options: [])
    ctx.restoreGState()

    // Month grid: 4x3 dots, coarse enough to survive downscaling to 16pt.
    let padX = side * 0.145
    let padY = side * 0.135
    let body = CGRect(x: rect.minX + padX,
                      y: rect.minY + padY,
                      width: side - padX * 2,
                      height: (side - headerH) - padY * 2)

    let cols = 4, rows = 3
    let dotR = side * 0.052
    let todayR = dotR * 1.5
    let todayCol = 2, todayRow = 1   // middle row, right of centre

    for row in 0..<rows {
        for col in 0..<cols {
            let cx = body.minX + (CGFloat(col) + 0.5) * body.width / CGFloat(cols)
            let cy = body.minY + (CGFloat(row) + 0.5) * body.height / CGFloat(rows)
            let isToday = (col == todayCol && row == todayRow)
            let r = isToday ? todayR : dotR
            ctx.setFillColor(isToday
                ? CGColor(red: 1.00, green: 0.23, blue: 0.19, alpha: 1)
                : CGColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1))
            ctx.fillEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        }
    }

    ctx.restoreGState()
}

func renderPNG(size: Int, to url: URL) {
    let space = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: size, height: size,
                              bitsPerComponent: 8, bytesPerRow: 0, space: space,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        fatalError("context")
    }
    ctx.setAllowsAntialiasing(true)
    ctx.interpolationQuality = .high
    drawIcon(size: CGFloat(size), context: ctx)

    guard let image = ctx.makeImage(),
          let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fatalError("image")
    }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

// macOS asset catalogs want each logical size at 1x and 2x.
let variants: [(size: Int, scale: Int)] = [
    (16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2),
    (256, 1), (256, 2), (512, 1), (512, 2),
]

let outDir = URL(fileURLWithPath: CommandLine.arguments[1])
try! FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

var entries: [String] = []
for v in variants {
    let px = v.size * v.scale
    let name = "icon_\(v.size)x\(v.size)\(v.scale == 2 ? "@2x" : "").png"
    renderPNG(size: px, to: outDir.appendingPathComponent(name))
    entries.append("""
        {
          "filename" : "\(name)",
          "idiom" : "mac",
          "scale" : "\(v.scale)x",
          "size" : "\(v.size)x\(v.size)"
        }
    """)
}

let contents = """
{
  "images" : [
\(entries.joined(separator: ",\n"))
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

"""
try! contents.write(to: outDir.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
print("wrote \(variants.count) PNGs + Contents.json")
