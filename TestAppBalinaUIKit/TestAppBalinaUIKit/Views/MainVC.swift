//
//  MainVC.swift
//  TestAppBalinaUIKit
//
//  Created by Alexandr Filovets on 24.10.24.
//

import UIKit

private enum TableSection: Int, CaseIterable {
    case photos = 0
    case loader
}

final class MainViewController: UIViewController {
    
    //MARK: Properties
    
    private lazy var mainTableView: UITableView = {
        var tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.key)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.key)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        return picker
    }()
    
    var viewModel: MainViewModelProtocol = MainViewModel()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getPhotos()
        configureUI()
        
        viewModel.onUpdateTableView = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                // Обновляем интерфейс здесь
                self.mainTableView.reloadData()
            }
        }
        
        viewModel.onPresentAlert = { [weak self] text, title in
            guard let self else { return }
            showAllert(text: text, title: title)
        }
    }
    
    //MARK: UIAlertController
    
    func showAllert(text: String, title: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    //MARK: UI
    
    private func configureUI() {
        // Отключаем автоматическое создание ограничений на основе autoresizing mask
        mainTableView.translatesAutoresizingMaskIntoConstraints = false

        // Добавляем таблицу на основное представление
        view.addSubview(mainTableView)

        // Настраиваем констрейнты вручную
        NSLayoutConstraint.activate([
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTableView.topAnchor.constraint(equalTo: view.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - MainViewController extension


//MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch TableSection.allCases[indexPath.section] {
        case .loader:
            viewModel.getPhotos()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAllert(text: "Device has no camera.", title: "Camera Error")
            return
        }
        viewModel.changeSentPhotoIndexPath(indexPath: indexPath)
        present(imagePicker, animated: true)
    }
}


//MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        TableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection.allCases[section] {
        case .photos:
            return viewModel.getNumberOfCells()
        case .loader:
            return viewModel.showLoader()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.key) as? PhotoCell,
              let loaderCell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.key) as? LoadingCell else { return UITableViewCell() }
        
        switch TableSection.allCases[indexPath.section] {
        case .photos:
            return viewModel.configurePhotoCell(indexPath: indexPath, cell: cell)
        case .loader:
            loaderCell.updateConstraints()
            return loaderCell
        }
    }
}


//MARK: UIImagePickerControllerDelegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.sendPhotoToServer(photo: image)
            viewModel.changeSentPhotoIndexPath(indexPath: nil)
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


private enum Constants {
    static let devName = Bundle.main.object(forInfoDictionaryKey: "DeveloperName") as? String
}

protocol MainViewModelProtocol {
    func sendPhotoToServer(photo: UIImage)
    func getPhotos()
    func changeSentPhotoIndexPath(indexPath: IndexPath?)
    func getNumberOfCells() -> Int
    func showLoader() -> Int
    func configurePhotoCell(indexPath: IndexPath, cell: PhotoCell) -> UITableViewCell
    
    var onUpdateTableView: (() -> Void)? { get set }
    var onPresentAlert: ((_ text: String, _ title: String) -> Void)? { get set }
}

final class MainViewModel: MainViewModelProtocol {
    
    var onPresentAlert: ((String, String) -> Void)?
    var onUpdateTableView: (() -> Void)?
   
    //MARK: - Properties
    
    private var imageCache = NSCache<NSString, UIImage>()
    private var alamofireProvider: NetworkProtocol = NetworkService()
    private var arrayPhotos: [Content] = []
    private var page = 0
    private var maxPage = 0
    private var isDownloadInProgress = true
    private var photoIndexPath: IndexPath!
    
    
    //MARK: - Business Logic
    
    func showLoader() -> Int {
        page <= maxPage ? 1 : 0
    }
    
    func getNumberOfCells() -> Int {
        arrayPhotos.count
    }
    
    func configurePhotoCell(indexPath: IndexPath, cell: PhotoCell) -> UITableViewCell {
        cell.prepareForReuse()
        guard var image = UIImage(systemName: "exclamationmark.icloud.fill") else { return UITableViewCell() }
        if let key = arrayPhotos[indexPath.row].image, let cashedImage = imageCache.object(forKey: key as NSString) {
            image = cashedImage
        }
        cell.configureUI(photo: image, text: arrayPhotos[indexPath.row].name)
        cell.updateConstraints()
        return cell
    }
    
    func changeSentPhotoIndexPath(indexPath: IndexPath?) {
        photoIndexPath = indexPath
    }
    
    func sendPhotoToServer(photo: UIImage) {
        guard let photoIndexPath = photoIndexPath else {
            onPresentAlert?("No photo index selected", "Error")
            return
        }
        alamofireProvider.sendPhotoToServer(photo: photo, id: arrayPhotos[photoIndexPath.row].id, userName: Constants.devName ?? "") { [weak self] result in
            guard let self, let onPresentAlert else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let responseString = String(data: data, encoding: .utf8) else { return }
                    onPresentAlert(responseString, "Data")
                case .failure(let error):
                    onPresentAlert(error.localizedDescription, "Error")
                }
            }
        }
    }
    
    func getPhotos() {
        guard isDownloadInProgress == true else { return }
        isDownloadInProgress = false
        alamofireProvider.getPhotos(page: page, completion: { [weak self] result in
            guard let self, let onPresentAlert else { return }
            switch result {
            case .success(let photos):
                photos.content.forEach({self.arrayPhotos.append($0)})
                self.maxPage = photos.totalPages
                self.page += 1
                self.loadImageToCache()
            case .failure(let error):
                onPresentAlert(error.localizedDescription,"Error")
                print("")
            }
        })
    }
    
    private func loadImageToCache() {
        let group = DispatchGroup()
        for info in arrayPhotos {
            group.enter()
            if let image = info.image, imageCache.object(forKey: image as NSString) == nil {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self, let loadImage = info.image?.image else { return }
                    self.imageCache.setObject(loadImage, forKey: image as NSString)
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        
        group.wait()
        
        group.notify(queue: .main) { [weak self] in
            guard let self, let onUpdateTableView else { return }
            self.isDownloadInProgress = true
            onUpdateTableView()
        }
    }
}
