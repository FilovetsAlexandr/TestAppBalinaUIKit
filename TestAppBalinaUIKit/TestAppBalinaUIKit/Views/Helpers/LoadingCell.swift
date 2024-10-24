//
//  LoadingCell.swift
//  TestAppBalinaUIKit
//
//  Created by Alexandr Filovets on 24.10.24.
//

import UIKit

final class LoadingCell: UITableViewCell {
    
    //MARK: - Properties
    static var key = "LoadingCell"
    
    private lazy var spinnerView: UIActivityIndicatorView = {
        var view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .medium
        view.color = .blue
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(spinnerView)
        spinnerView.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    override func updateConstraints() {
        super.updateConstraints()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                spinnerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                spinnerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                spinnerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                spinnerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                spinnerView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
}
