import SwiftUI
#if os(macOS)
import AppKit
#endif

struct PropertyImageView: View {
    let property: Property
    let height: CGFloat

    var body: some View {
        Group {
            if let image = imageFromPhotoPath {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: property.imageName.isEmpty ? "house" : property.imageName)
                    .font(.system(size: min(height * 0.36, 72)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.yellow)
                    .foregroundStyle(.black)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
    }

    private var imageFromPhotoPath: NSImage? {
        #if os(macOS)
        guard !property.photoPath.isEmpty else {
            return nil
        }

        return NSImage(contentsOfFile: property.photoPath)
        #else
        return nil
        #endif
    }
}
