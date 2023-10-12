import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: BinanceEndpoint) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: BinanceEndpoint) async throws -> T {
        try await session
            .request(endpoint.url, parameters: endpoint.parameters)
            .validate()
            .serializingDecodable(T.self)
            .value
    }
}
