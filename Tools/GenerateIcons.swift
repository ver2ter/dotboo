import AppKit

@MainActor
func exportIcons(source: String, to path: String) throws {
    guard let artwork = NSImage(contentsOfFile: source) else {
        throw NSError(domain: "DotBoo.IconGeneration", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Cannot load the logo artwork."])
    }
    let directory = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    for size in [16, 32, 128, 256, 512] {
        for scale in [1, 2] {
            let pixels = size * scale
            guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
                let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
                throw NSError(domain: "DotBoo.IconGeneration", code: 2)
            }
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = context
            context.imageInterpolation = .high
            let side = CGFloat(pixels)
            let tile = NSRect(x: side * 0.06, y: side * 0.06,
                              width: side * 0.88, height: side * 0.88)
            NSBezierPath(roundedRect: tile, xRadius: side * 0.19,
                         yRadius: side * 0.19).addClip()
            artwork.draw(in: tile, from: .zero, operation: .copy, fraction: 1)
            NSGraphicsContext.restoreGraphicsState()
            guard let png = bitmap.representation(using: .png, properties: [:]) else {
                throw NSError(domain: "DotBoo.IconGeneration", code: 3)
            }
            let filename = "icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"
            try png.write(to: directory.appendingPathComponent(filename))
        }
    }
}

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: generate-icons <source.png> <output.iconset>\n", stderr)
    exit(64)
}
try MainActor.assumeIsolated {
    try exportIcons(source: CommandLine.arguments[1], to: CommandLine.arguments[2])
}
