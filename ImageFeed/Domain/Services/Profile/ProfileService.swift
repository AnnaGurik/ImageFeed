import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }

        let request = makeRequest(token: token)
        
        let task = object(for: request) { [weak self] result in
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self?.profile = profile
                completion(.success(Profile(profileResult: profileResult)))
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
    
    private func object(for request: URLRequest, completion: @escaping (Result<ProfileResult, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func makeRequest(token: String) -> URLRequest {
        guard let url = URL(string: "/me", relativeTo: Constants.DefaultBaseURL) else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
