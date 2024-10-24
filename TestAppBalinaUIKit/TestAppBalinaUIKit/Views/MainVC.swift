//
//  MainVC.swift
//  TestAppBalinaUIKit
//
//  Created by Alexandr Filovets on 24.10.24.
//

import UIKit

final class MainVC: UIViewController {
    
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
    
    private var networkService: NetworkProtocol = NetworkService()
    private var arrayPhotos: [Content] = []
    private var page = 1
    private var isDownloadInProgress = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadPhotos()
    }
    
    //MARK: - Load Photos
    private func loadPhotos() {
        guard !isDownloadInProgress else { return }
        isDownloadInProgress = true
        
        networkService.getPhotos(page: page) { [weak self] result in
            DispatchQueue.main.async {
                self?.isDownloadInProgress = false
                switch result {
                case .success(let photos):
                    self?.arrayPhotos.append(contentsOf: photos.content)
                    self?.page += 1
                    self?.mainTableView.reloadData()
                case .failure(let error):
                    self?.showAlert(text: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    //MARK: - UI Configuration
    private func configureUI() {
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: view.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    //MARK: - Alert Presentation
    private func showAlert(text: String, title: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource и UITableViewDelegate
extension MainVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.key) as? PhotoCell else {
            return UITableViewCell()
        }
        let content = arrayPhotos[indexPath.row]
        let image = UIImage(systemName: "photo") // Placeholder image
        
        if let imageUrl = content.image, let url = URL(string: imageUrl) {
            // Загрузка изображения по URL
        }
        
        cell.configureUI(photo: image!, text: content.name ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(text: "Device has no camera.", title: "Error")
            return
        }
        present(imagePicker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension MainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            let selectedPhoto = arrayPhotos.first?.id ?? 0 // Получаем идентификатор выбранного фото
            networkService.sendPhotoToServer(photo: image, id: selectedPhoto, userName: "Filovets Alexandr Vladimirovich") { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let responseString = String(data: data, encoding: .utf8) {
                            self?.showAlert(text: responseString, title: "Success")
                        } else {
                            self?.showAlert(text: "Invalid response", title: "Error")
                        }
                    case .failure(let error):
                        self?.showAlert(text: error.localizedDescription, title: "Error")
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
    
}
