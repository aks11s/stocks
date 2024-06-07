import Foundation

final class OrderStorage {

    static let shared = OrderStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Key {
        static let orders = "orders.all"
    }

    // newest first
    var all: [Order] {
        get {
            guard let data = defaults.data(forKey: Key.orders),
                  let entries = try? JSONDecoder().decode([Order].self, from: data)
            else { return [] }
            return entries
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Key.orders)
        }
    }

    // MARK: - Mutations

    func add(_ order: Order) {
        var current = all
        current.insert(order, at: 0)
        all = current
    }

    func cancel(id: UUID) {
        updateStatus(id: id, to: .cancelled)
    }

    func fill(id: UUID) {
        updateStatus(id: id, to: .filled)
    }

    private func updateStatus(id: UUID, to status: OrderStatus) {
        var current = all
        guard let index = current.firstIndex(where: { $0.id == id }) else { return }
        current[index].status = status
        all = current
    }
}
