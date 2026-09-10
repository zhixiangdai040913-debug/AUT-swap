import AppKit
import SwiftUI

enum ListingImageStorage {
    private static let folderName = "AUTSwapListingImages"

    static var appSupportRoot: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func listingDirectory(for listingId: String) -> URL {
        let dir = appSupportRoot.appendingPathComponent(listingId, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func saveImages(listingId: String, from sourceURLs: [URL]) -> [String] {
        let dir = listingDirectory(for: listingId)
        var saved: [String] = []
        for (index, url) in sourceURLs.prefix(6).enumerated() {
            let name = "photo_\(index).jpg"
            let dest = dir.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: dest)
            if let data = try? Data(contentsOf: url),
               let image = NSImage(data: data),
               let jpeg = jpegData(from: image) {
                try? jpeg.write(to: dest)
                saved.append(name)
            }
        }
        return saved
    }

    static func loadImage(listingId: String, fileName: String) -> NSImage? {
        let url = listingDirectory(for: listingId).appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return NSImage(contentsOf: url)
    }

    static func loadBundleImage(named fileName: String) -> NSImage? {
        let base = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension.isEmpty ? "jpg" : (fileName as NSString).pathExtension
        let candidates = [
            Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: "ListingImages"),
            Bundle.main.url(forResource: base, withExtension: ext, subdirectory: "ListingImages"),
            Bundle.main.url(forResource: base, withExtension: ext)
        ]
        for url in candidates.compactMap({ $0 }) {
            if let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }

    private static func jpegData(from image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.85])
    }
}

enum PhotoPickerMac {
    static func pickImages(maxCount: Int, completion: @escaping ([URL]) -> Void) {
        let panel = NSOpenPanel()
        panel.title = "Choose listing photos"
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["jpg", "jpeg", "png", "heic", "webp"]
        panel.begin { response in
            DispatchQueue.main.async {
                if response == .OK {
                    completion(Array(panel.urls.prefix(maxCount)))
                } else {
                    completion([])
                }
            }
        }
    }
}

struct ListingPhotoPicker: View {
    @Binding var selectedURLs: [URL]
    let maxCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Photos (up to \(maxCount))")
                    .font(.headline)
                Spacer()
                Button("Add Photos") { pickPhotos() }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(SwapTheme.orange)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(selectedURLs.enumerated()), id: \.offset) { index, url in
                        ZStack(alignment: .topTrailing) {
                            if let image = NSImage(contentsOf: url) {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 72, height: 72)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                            Button(action: { selectedURLs.remove(at: index) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .offset(x: 4, y: -4)
                        }
                    }
                    if selectedURLs.count < maxCount {
                        Button(action: pickPhotos) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(SwapTheme.orange.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(width: 72, height: 72)
                                .overlay(Image(systemName: "plus").foregroundColor(SwapTheme.orange))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    private func pickPhotos() {
        PhotoPickerMac.pickImages(maxCount: maxCount - selectedURLs.count) { urls in
            selectedURLs.append(contentsOf: urls)
        }
    }
}

struct ListingThumbnailView: View {
    let item: ListingItem
    var cornerRadius: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            Group {
                if let image = primaryImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [item.imageColor, item.imageColor.opacity(0.75)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Image(systemName: item.imageSymbol)
                            .font(.system(size: min(geo.size.width, geo.size.height) * 0.38))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var primaryImage: NSImage? {
        if let name = item.imageNames.first {
            if let userImage = ListingImageStorage.loadImage(listingId: item.id, fileName: name) {
                return userImage
            }
            if let bundleImage = ListingImageStorage.loadBundleImage(named: name) {
                return bundleImage
            }
        }
        return nil
    }
}

struct ListingImageGalleryView: View {
    let item: ListingItem
    @State private var selectedIndex = 0

    private var images: [NSImage] {
        item.imageNames.compactMap { name in
            ListingImageStorage.loadImage(listingId: item.id, fileName: name)
                ?? ListingImageStorage.loadBundleImage(named: name)
        }
    }

    var body: some View {
        Group {
            if images.isEmpty {
                ListingThumbnailView(item: item, cornerRadius: 12)
                    .aspectRatio(1, contentMode: .fit)
            } else {
                VStack(spacing: 8) {
                    if let image = images[safe: selectedIndex] ?? images.first {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                            .cornerRadius(12)
                    }
                    if images.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                    Image(nsImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 56, height: 56)
                                        .clipped()
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(selectedIndex == index ? SwapTheme.orange : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture { selectedIndex = index }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
