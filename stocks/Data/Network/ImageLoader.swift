import UIKit

// Lightweight async image loader with an in-memory cache.
// No disk cache — good enough for token icons in a small app.
final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func cachedImage(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func load(from url: URL) async -> UIImage? {
        if let cached = cachedImage(for: url) { return cached }

        guard let (data, response) = try? await session.data(from: url),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let image = UIImage(data: data)
        else { return nil }

        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
