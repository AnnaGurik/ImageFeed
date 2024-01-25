import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }
        
        let request = makeRequest(username: username, token: OAuth2TokenStorage().token ?? "")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let profileImageUrl = userResult.profileImage.small
                self?.avatarURL = profileImageUrl
                completion(.success(profileImageUrl))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageUrl]
                )
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
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                guard 200 ..< 300 ~= statusCode else { return }
                fulfillCompletionOnTheMainThread(.success(data))
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        task.resume()
        return task
    }
    
    private func makeRequest(username: String, token: String) -> URLRequest {
        guard let url = URL(string: "/users/\(username)", relativeTo: Constants.defaultBaseURL) else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
