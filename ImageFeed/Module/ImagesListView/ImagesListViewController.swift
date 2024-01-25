import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func setupTableView()
    func updateTableViewAnimated(_ newPhotos: [Photo])
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    @IBOutlet private weak var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
    
    func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let photoUrl = photos[indexPath.row].largeImageURL
            viewController.fullImageURL = URL(string: photoUrl)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count-1 {
            presenter?.fetchPhotosNextPage()
        }
    }
    
    func updateTableViewAnimated(_ newPhotos: [Photo]) {
        let oldCount = photos.count
        let newCount = newPhotos.count
        photos = newPhotos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        
        let photo = photos[indexPath.row]
        if let imageUrl = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "imagePlaceholder")) { [weak self] _ in
                self?.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        let isLiked = photos[indexPath.row].isLiked
        cell.setIsLiked(isLiked: isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scaleImage = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scaleImage + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        presenter?.changeLike(photoId: photo.id, isLike: photo.isLiked, { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let newPhotos):
                self.photos = newPhotos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
            case .failure:
                self.showAlert(title: "Что-то пошло не так", description: nil)
            }
        })
    }
}
