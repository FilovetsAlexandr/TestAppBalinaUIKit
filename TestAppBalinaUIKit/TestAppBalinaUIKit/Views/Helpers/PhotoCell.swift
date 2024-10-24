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
        view.backgroundColor = .blue.withAlphaComponent(0.5)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 5, height: 4)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var photoImage: UIImageView = {
        var view = UIImageView()
        view.contentMode = .scaleToFill
        view.tintColor = .black
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    //MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(mainView)
        mainView.addSubview(photoImage)
        mainView.addSubview(nameLabel)
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
    
    override func updateConstraints() {
        super.updateConstraints()
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        photoImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImage.heightAnchor.constraint(equalToConstant: 100),
            photoImage.widthAnchor.constraint(equalToConstant: 100),
            photoImage.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8),
            photoImage.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 24),
            photoImage.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -24)
        ])
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: photoImage.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 16)
        ])
    }
    
    func configureUI(photo: UIImage, text: String) {
        photoImage.image = photo
        nameLabel.text = text
    }
}
