import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {}
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<[Photo], Error>) -> Void) {}
}
