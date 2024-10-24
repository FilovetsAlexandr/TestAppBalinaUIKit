//
//  String+Ext.swift
//  TestAppBalinaUIKit
//
//  Created by Alexandr Filovets on 24.10.24.
//

import UIKit

extension String {
    var image: UIImage {
        guard let apiURL = URL(string: self) else { return UIImage() }
        let data = try! Data(contentsOf: apiURL)
        guard let image = UIImage(data: data) else { return UIImage() }
        return image
    }
}
