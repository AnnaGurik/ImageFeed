import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    private var nextPage: Int = 0
    
    func fetchPhotosNextPage() {
        if task == nil {
            if let lastLoadedPage = lastLoadedPage {
                nextPage = lastLoadedPage + 1
            } else {
                nextPage = 1
            }
        }
        
        let request = makeRequest(page: nextPage)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let newCodedPhotos):
                let newPhotos = newCodedPhotos.map({ Photo(photoResult: $0) })
                self?.photos.append(contentsOf: newPhotos)
                NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: nil)
                self?.lastLoadedPage = self?.nextPage
                self?.task = nil
            case .failure(let failure):
                break
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(page: Int) -> URLRequest {
        guard 
            let url = URL(string: "/photos?page=\(page)", relativeTo: Constants.DefaultBaseURL),
            let token = OAuth2TokenStorage().token
        else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
