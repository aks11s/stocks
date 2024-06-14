import UIKit
import ObjectiveC

private var tokenKey: UInt8 = 0
private var taskKey: UInt8 = 0

extension UIImageView {

    // the ticker this image view shows right now — if a cell gets reused
    // while an icon is still loading, we compare against this and drop the late image
    private var currentToken: String? {
        get { objc_getAssociatedObject(self, &tokenKey) as? String }
        set { objc_setAssociatedObject(self, &tokenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var loadTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &taskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setToken(_ ticker: String, size: CGFloat = 40) {
        cancelTokenLoad()
        currentToken = ticker
        image = TokenPlaceholder.image(for: ticker, size: size)

        guard let url = TokenIcon.url(for: ticker) else { return }

        if let cached = ImageLoader.shared.cachedImage(for: url) {
            image = cached
            return
        }

        loadTask = Task { @MainActor [weak self] in
            let loaded = await ImageLoader.shared.load(from: url)
            guard let self, let loaded,
                  !Task.isCancelled,
                  self.currentToken == ticker
            else { return }
            self.image = loaded
        }
    }

    func cancelTokenLoad() {
        loadTask?.cancel()
        loadTask = nil
    }
}
