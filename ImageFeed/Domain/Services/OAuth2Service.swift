import Foundation

final class OAuth2Service {
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else { return }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                fulfillCompletionOnTheMainThread(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse,
               (200...299).contains(response.statusCode), let data = data {
                do {
                    let decodeData = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    fulfillCompletionOnTheMainThread(.success(decodeData.accessToken))
                } catch {
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            }
            
            
        }
        .resume()
    }
}

