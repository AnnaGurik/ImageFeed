import Foundation

final class OAuth2Service {
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var components = URLComponents(string: "https://unsplash.com/oauth/token")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.AccessKey),
            URLQueryItem(name: "client_secret", value: Constants.SecretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        let url = components.url!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse,
               (200...299).contains(response.statusCode), let data = data {
                do {
                    let decodeData = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        completion(.success(decodeData.accessToken))
                } catch {
                    completion(.failure(error))
                }
            }
            
            
        }
        .resume()
    }
}

