import ImageFeed
import UIKit
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var photosDidLoad = false
    var countPhotos = 0
    var presenter: ImagesListPresenterProtocol?
    
    private var photos: [Photo] = []
    
    func updateTableViewAnimated(_ newPhotos: [Photo]) {
        self.photos = newPhotos
        self.countPhotos = self.photos.count
        photosDidLoad = true
    }
    
    func setupTableView() {}
}
