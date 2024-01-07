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
        
        let task = object(for: request) { [weak self] result in
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
    
    private func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = urlSession.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        })
        task.resume()
        return task
    }
    
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func makeRequest(code: String) -> URLRequest {
        guard
            let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.AccessKey)"
                + "&&client_secret=\(Constants.SecretKey)"
                + "&&redirect_uri=\(Constants.RedirectURI)"
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
