import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    func fetch<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { data, response, error in
        
            DispatchQueue.main.async {
                if error != nil {
                    completion(.failure(NetworkError.taskFail))
                    return
                }
                
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(NetworkError.decodingFail))
                }
            }
        }.resume()
    }
}
