import Foundation

class BookService {
    private let apiKey = "8d933b353a5ff1929e64c133b28287fd"
    private let searchURL = "https://dapi.kakao.com/v3/search/book"
    
    private func createRequest(query: String) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: searchURL) else {
            throw NetworkError.invalidUrl
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        guard let url = urlComponents.url else {
            throw NetworkError.invalidUrl
        }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]
        return request
    }
    
    // 외부에서 호출할 함수
    func search(query: String, completion: @escaping (Result<BookResponse, Error>) -> Void) {
        do {
            let request = try createRequest(query: query)
            NetworkManager.shared.fetch(request: request) { result in
                completion(result)
            }
        } catch {
            completion(.failure(error))
        }
    }
}
