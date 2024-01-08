import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<[Photo], Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.DidChangeNotification, object: nil)
    }
    
    func viewDidLoad() {
        imagesListObserve()
        view?.setupTableView()
    }
    
    private func imagesListObserve() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.view?.updateTableViewAnimated(self.imagesListService.photos)
        }
        imagesListService.fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<[Photo], Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                completion(.success(self.imagesListService.photos))
                UIBlockingProgressHUD.dismiss()
            case .failure(let failure):
                completion(.failure(failure))
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
