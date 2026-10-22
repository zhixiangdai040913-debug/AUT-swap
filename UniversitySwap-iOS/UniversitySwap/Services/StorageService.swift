import Foundation
import FirebaseStorage
import UIKit

enum StorageServiceError: LocalizedError {
    case compressionFailed
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Could not prepare the photo for upload."
        case .underlying(let message):
            return message
        }
    }
}

final class StorageService {
    static let shared = StorageService()

    private var storage: Storage { Storage.storage() }

    private init() {}

    /// Uploads JPEG listing photos and returns their download URLs (in order).
    func uploadListingPhotos(
        listingId: String,
        sellerId: String,
        photoData: [Data],
        maxDimension: CGFloat = 1600,
        compressionQuality: CGFloat = 0.72
    ) async throws -> [URL] {
        guard !photoData.isEmpty else { return [] }

        var urls: [URL] = []
        urls.reserveCapacity(photoData.count)

        for (index, data) in photoData.enumerated() {
            let jpeg = try compress(data, maxDimension: maxDimension, quality: compressionQuality)
            let path = "listings/\(sellerId)/\(listingId)/\(index).jpg"
            let ref = storage.reference().child(path)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            do {
                _ = try await ref.putDataAsync(jpeg, metadata: metadata)
                let url = try await ref.downloadURL()
                urls.append(url)
            } catch {
                throw StorageServiceError.underlying(error.localizedDescription)
            }
        }

        return urls
    }

    private func compress(_ data: Data, maxDimension: CGFloat, quality: CGFloat) throws -> Data {
        guard let image = UIImage(data: data) else {
            throw StorageServiceError.compressionFailed
        }

        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxDimension ? maxDimension / longest : 1
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

        guard let jpeg = resized.jpegData(compressionQuality: quality) else {
            throw StorageServiceError.compressionFailed
        }
        return jpeg
    }
}
