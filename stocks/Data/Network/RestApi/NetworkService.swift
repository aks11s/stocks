import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: OKXEndpoint) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let session: Session

    // OKX wraps every response in {"code":"0","data":[...]}
    private struct OKXResponse<T: Decodable>: Decodable {
        let data: T
    }

    init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: OKXEndpoint) async throws -> T {
        let envelope = try await session
            .request(endpoint.url, parameters: endpoint.parameters)
            .validate()
            .serializingDecodable(OKXResponse<T>.self)
            .value
        return envelope.data
    }
}
