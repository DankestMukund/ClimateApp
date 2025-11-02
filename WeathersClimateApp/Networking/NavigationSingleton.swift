import Foundation

enum NetworkError: Error {
    case invalidURL
}

class NetworkManager {
    
    // Your singleton pattern is perfect.
    static let shared = NetworkManager()
    private init() {}
    
    func fetchData<T: Codable>(from urlString: String) async throws -> T {
        
  
        guard let url = URL(string: urlString) else {
            // 4. If it's bad, throw our custom error. NO CRASH.
            throw NetworkError.invalidURL
        }
        
        // The rest of your code was great.
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Error decoding JSON: \(error)")
            throw error
        }
    }
}
