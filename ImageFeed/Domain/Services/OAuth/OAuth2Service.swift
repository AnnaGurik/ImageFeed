import Foundation

final class OAuth2Service {
    private let urlSession = URLSession.shared 
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                return
            }
        } else {
            if lastCode == code {
                return
            }
        }
        lastCode = code
        
        let request = makeRequest(code: code)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let token):
                OAuth2TokenStorage().token = token.accessToken
                completion(.success(token.accessToken))
                self?.lastCode = nil
            case .failure(let failure):
                completion(.failure(failure))
            }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest {
        guard
            let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: URL(string: "https://unsplash.com")
            )
        else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let resultData = try JSONDecoder().decode(T.self, from: data)
                        fulfillCompletionOnTheMainThread(.success(resultData))
                    } catch {
                        fulfillCompletionOnTheMainThread(.failure(error))
                    }
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        })
        return task
    }
}
