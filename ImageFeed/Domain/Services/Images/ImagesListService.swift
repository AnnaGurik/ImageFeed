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
        
        let request = makeRequestPage(page: nextPage)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let newCodedPhotos):
                let newPhotos = newCodedPhotos.map({ Photo(photoResult: $0) })
                self?.photos.append(contentsOf: newPhotos)
                NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: nil)
                self?.lastLoadedPage = self?.nextPage
                self?.task = nil
            case .failure:
                break
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if task != nil {
            return
        }
        
        let request = makeRequestLike(photoId: photoId, isLike: isLike)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<Like, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let like):
                if let index = self.photos.firstIndex(where: { $0.id == like.photo.id }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(photoResult: like.photo)
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let failure):
                completion(.failure(failure))
                break
            }
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequestPage(page: Int) -> URLRequest {
        guard
            let url = URL(string: "/photos?page=\(page)", relativeTo: Constants.defaultBaseURL),
            let token = OAuth2TokenStorage().token
        else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeRequestLike(photoId: String, isLike: Bool) -> URLRequest {
        guard
            let url = URL(string: "/photos/\(photoId)/like", relativeTo: Constants.defaultBaseURL),
            let token = OAuth2TokenStorage().token
        else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
