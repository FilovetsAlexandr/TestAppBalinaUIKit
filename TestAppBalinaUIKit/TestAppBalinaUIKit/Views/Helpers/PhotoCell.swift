//
//  PhotoCell.swift
//  TestAppBalinaUIKit
//
//  Created by Alexandr Filovets on 24.10.24.
//

import UIKit

final class PhotoCell: UITableViewCell {

    //MARK: - Properties

    static var key = "PhotoCell"

    private lazy var mainView: UIView = {
        var view = UIView()
        view.backgroundColor = .systemGray6 // Нейтральный цвет
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var photoImage: UIImageView = {
        var view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true // Обрезка для круглой формы
        view.layer.cornerRadius = 50 // Делает изображение круглым при размере 100x100
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()

    private lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .systemGray // Нейтральный цвет текста
        return label
    }()

    //MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(mainView)
        mainView.addSubview(photoImage)
        mainView.addSubview(nameLabel)
        setupConstraints() // Настраиваем констрейнты
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - UI
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.image = UIImage()
        nameLabel.text = ""
    }

    private func setupConstraints() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        photoImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // mainView constraints
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50), // Увеличен отступ сверху
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50), // Увеличен отступ снизу
            
            // photoImage constraints
            photoImage.heightAnchor.constraint(equalToConstant: 100),
            photoImage.widthAnchor.constraint(equalToConstant: 100),
            photoImage.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            photoImage.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),

            // nameLabel constraints
            nameLabel.leadingAnchor.constraint(equalTo: photoImage.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: mainView.centerYAnchor)
        ])
    }

    func configureUI(photo: UIImage?, text: String) {
           if let image = photo {
               photoImage.image = image
           } else {
               photoImage.image = UIImage(systemName: "questionmark") // Системная иконка
           }
           nameLabel.text = text
       }
}
