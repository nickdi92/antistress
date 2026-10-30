// Renders an SVG to an opaque square PNG (RGB, no alpha, no metadata).
// Usage: swift tools/render-icon.swift <in.svg> <out.png> <px>
import AppKit
import ImageIO
import UniformTypeIdentifiers

func fail(_ message: String, code: Int32 = 1) -> Never {
    FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
    exit(code)
}

let args = CommandLine.arguments
guard args.count == 4, let px = Int(args[3]), px > 0 else {
    fail("usage: render-icon.swift <in.svg> <out.png> <px>", code: 64)
}
guard let image = NSImage(contentsOf: URL(fileURLWithPath: args[1])) else { fail("cannot load \(args[1])") }

// RGBX: 8 bits per channel, the fourth byte is ignored, so the result has no alpha channel
guard let ctx = CGContext(
    data: nil, width: px, height: px, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else { fail("cannot create bitmap context") }
ctx.interpolationQuality = .high

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
image.draw(in: NSRect(x: 0, y: 0, width: px, height: px))
NSGraphicsContext.restoreGraphicsState()

guard let cg = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: args[2]) as CFURL, UTType.png.identifier as CFString, 1, nil)
else { fail("cannot encode \(args[2])") }
CGImageDestinationAddImage(dest, cg, nil)
guard CGImageDestinationFinalize(dest) else { fail("cannot write \(args[2])") }
